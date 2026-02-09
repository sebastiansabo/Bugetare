"""
RAG Service

Retrieval Augmented Generation service for semantic search and context retrieval.
Indexes JARVIS data (invoices, transactions, etc.) for AI queries.
"""

from typing import Optional, List, Dict, Any
from decimal import Decimal

from core.database import get_db, get_cursor, release_db
from core.utils.logging_config import get_logger
from ..models import RAGDocument, RAGSourceType, RAGSource, ServiceResult
from ..config import AIAgentConfig
from ..exceptions import RAGError
from ..repositories import RAGDocumentRepository
from .embedding_service import EmbeddingService

logger = get_logger('jarvis.ai_agent.services.rag')


class RAGService:
    """
    RAG service for document indexing and retrieval.

    Handles:
    - Indexing JARVIS data (invoices, transactions, companies)
    - Semantic search using embeddings
    - Text search fallback when pgvector unavailable
    - Context formatting for LLM prompts
    """

    def __init__(self, config: Optional[AIAgentConfig] = None):
        """
        Initialize RAG service.

        Args:
            config: Optional AIAgentConfig
        """
        self.config = config or AIAgentConfig()
        self.embedding_service = EmbeddingService(config)
        self.document_repo = RAGDocumentRepository()

        # Check capabilities
        self._has_embeddings = self.embedding_service.is_available()
        self._has_pgvector = None

        logger.info(f"RAG Service initialized (embeddings: {self._has_embeddings})")

    def search(
        self,
        query: str,
        limit: int = 5,
        company_id: Optional[int] = None,
        source_types: Optional[List[RAGSourceType]] = None,
    ) -> List[RAGSource]:
        """
        Search for relevant documents.

        Uses vector similarity if available, otherwise text search.

        Args:
            query: Search query
            limit: Maximum results
            company_id: Optional company filter for access control
            source_types: Optional source type filter

        Returns:
            List of RAGSource results with scores
        """
        if not query or not query.strip():
            return []

        try:
            # Check pgvector availability
            if self._has_pgvector is None:
                self._has_pgvector = self.document_repo.has_pgvector()

            documents = []

            # Try vector search first
            if self._has_pgvector and self._has_embeddings:
                try:
                    query_embedding = self.embedding_service.generate_embedding(query)
                    documents = self.document_repo.search_by_vector(
                        embedding=query_embedding,
                        limit=limit,
                        company_id=company_id,
                        source_types=source_types,
                        min_score=self.config.rag_min_similarity,
                    )
                    logger.debug(f"Vector search returned {len(documents)} results")
                except Exception as e:
                    logger.warning(f"Vector search failed, falling back to text: {e}")
                    documents = []

            # Fallback to text search
            if not documents:
                documents = self.document_repo.search_by_text(
                    query=query,
                    limit=limit,
                    company_id=company_id,
                    source_types=source_types,
                )
                logger.debug(f"Text search returned {len(documents)} results")

            # Convert to RAGSource format
            return [
                RAGSource(
                    doc_id=doc.id,
                    score=doc.score,
                    snippet=self._create_snippet(doc.content),
                    source_type=doc.source_type.value,
                    source_id=doc.source_id,
                    metadata=doc.metadata,
                )
                for doc in documents
            ]

        except Exception as e:
            logger.error(f"RAG search failed: {e}")
            return []

    # Metadata keys to display per source type
    METADATA_DISPLAY_KEYS = {
        'invoice': [
            ('supplier', 'Supplier'), ('invoice_number', 'Invoice'), ('date', 'Date'),
            ('amount', 'Amount'), ('currency', 'Currency'),
        ],
        'transaction': [
            ('vendor_name', 'Vendor'), ('amount', 'Amount'), ('currency', 'Currency'),
            ('date', 'Date'), ('status', 'Status'),
        ],
        'company': [('name', 'Company'), ('cui', 'CUI')],
        'department': [('name', 'Department'), ('company', 'Company'), ('brand', 'Brand')],
        'employee': [('name', 'Employee'), ('department', 'Department'), ('company', 'Company'), ('role', 'Role')],
        'event': [('name', 'Event'), ('company', 'Company'), ('start_date', 'Start'), ('end_date', 'End')],
        'efactura': [
            ('invoice_number', 'Invoice'), ('partner_name', 'Partner'), ('amount', 'Amount'),
            ('currency', 'Currency'), ('date', 'Date'), ('direction', 'Direction'),
        ],
    }

    def format_context(
        self,
        sources: List[RAGSource],
        max_tokens: int = 2000,
    ) -> str:
        """
        Format RAG sources into context string for LLM prompt.

        Args:
            sources: List of RAG sources
            max_tokens: Maximum approximate tokens for context

        Returns:
            Formatted context string
        """
        if not sources:
            return ""

        context_parts = []
        approx_tokens = 0

        for i, source in enumerate(sources, 1):
            header = f"[Source {i}: {source.source_type}]"

            # Build metadata using source-type-aware keys
            meta_parts = []
            if source.metadata:
                display_keys = self.METADATA_DISPLAY_KEYS.get(source.source_type, [])
                for key, label in display_keys:
                    val = source.metadata.get(key)
                    if val:
                        meta_parts.append(f"{label}: {val}")

            meta_str = " | ".join(meta_parts) if meta_parts else ""

            entry = f"{header}\n"
            if meta_str:
                entry += f"{meta_str}\n"
            entry += f"{source.snippet}\n"

            entry_tokens = len(entry) // 4
            if approx_tokens + entry_tokens > max_tokens:
                break

            context_parts.append(entry)
            approx_tokens += entry_tokens

        return "\n".join(context_parts)

    def index_invoice(
        self,
        invoice_id: int,
        company_id: Optional[int] = None,
    ) -> ServiceResult:
        """
        Index an invoice for RAG search.

        Args:
            invoice_id: Invoice ID to index
            company_id: Company ID for access control

        Returns:
            ServiceResult with RAGDocument
        """
        try:
            # Fetch invoice data
            invoice_data = self._fetch_invoice_data(invoice_id)
            if not invoice_data:
                return ServiceResult(success=False, error="Invoice not found")

            # Build searchable content
            content = self._build_invoice_content(invoice_data)
            content_hash = self.embedding_service.compute_content_hash(content)

            # Check if already indexed
            existing = self.document_repo.get_by_source(
                RAGSourceType.INVOICE, invoice_id
            )

            if existing and existing.content_hash == content_hash:
                logger.debug(f"Invoice {invoice_id} already indexed, no changes")
                return ServiceResult(success=True, data=existing)

            # Build metadata
            metadata = {
                'invoice_number': invoice_data.get('invoice_number'),
                'supplier': invoice_data.get('supplier'),
                'date': str(invoice_data.get('invoice_date', '')),
                'amount': str(invoice_data.get('invoice_value', '')),
                'currency': invoice_data.get('currency', 'RON'),
            }

            # Generate embedding if available
            embedding = None
            if self._has_embeddings:
                try:
                    embedding = self.embedding_service.generate_embedding(content)
                except Exception as e:
                    logger.warning(f"Failed to generate embedding: {e}")

            # Create or update document
            document = RAGDocument(
                source_type=RAGSourceType.INVOICE,
                source_id=invoice_id,
                source_table='invoices',
                content=content,
                content_hash=content_hash,
                embedding=embedding,
                metadata=metadata,
                company_id=company_id or invoice_data.get('company_id'),
            )

            if existing:
                # Update existing
                if embedding:
                    self.document_repo.update_embedding(
                        existing.id, embedding, content_hash
                    )
                document.id = existing.id
            else:
                # Create new
                document = self.document_repo.create(document)

            logger.info(f"Indexed invoice {invoice_id}")
            return ServiceResult(success=True, data=document)

        except Exception as e:
            logger.error(f"Failed to index invoice {invoice_id}: {e}")
            return ServiceResult(success=False, error=str(e))

    def index_invoices_batch(
        self,
        limit: int = 100,
    ) -> ServiceResult:
        """
        Index multiple invoices in batch.

        Args:
            limit: Maximum invoices to process

        Returns:
            ServiceResult with count of indexed invoices
        """
        try:
            conn = get_db()
            cursor = get_cursor(conn)

            # Get invoices not yet indexed or with changed content
            cursor.execute("""
                SELECT i.id
                FROM invoices i
                LEFT JOIN ai_agent.rag_documents r
                    ON r.source_type = 'invoice'
                    AND r.source_id = i.id
                    AND r.is_active = TRUE
                WHERE (r.id IS NULL
                   OR r.updated_at < i.updated_at)
                  AND i.deleted_at IS NULL
                ORDER BY i.updated_at DESC
                LIMIT %s
            """, (limit,))

            invoices = cursor.fetchall()
            release_db(conn)

            indexed = 0
            for inv in invoices:
                result = self.index_invoice(inv['id'])
                if result.success:
                    indexed += 1

            logger.info(f"Batch indexed {indexed} invoices")
            return ServiceResult(success=True, data={'indexed': indexed})

        except Exception as e:
            logger.error(f"Batch indexing failed: {e}")
            return ServiceResult(success=False, error=str(e))

    def get_stats(self) -> Dict[str, Any]:
        """
        Get RAG statistics.

        Returns:
            Dict with document counts and capabilities
        """
        counts = self.document_repo.count_by_source_type()

        return {
            'total_documents': sum(counts.values()),
            'by_source_type': counts,
            'has_pgvector': self.document_repo.has_pgvector(),
            'has_embeddings': self._has_embeddings,
        }

    def _fetch_invoice_data(self, invoice_id: int) -> Optional[Dict]:
        """Fetch invoice data from database."""
        conn = get_db()
        cursor = get_cursor(conn)

        try:
            cursor.execute("""
                SELECT i.*,
                       a.company as allocated_company,
                       a.brand as allocated_brand,
                       a.department as allocated_department,
                       a.subdepartment as allocated_subdepartment
                FROM invoices i
                LEFT JOIN allocations a ON a.invoice_id = i.id
                WHERE i.id = %s
                LIMIT 1
            """, (invoice_id,))

            return cursor.fetchone()

        finally:
            release_db(conn)

    def _build_invoice_content(self, invoice_data: Dict) -> str:
        """Build searchable content from invoice data."""
        parts = []

        # Core fields
        if invoice_data.get('supplier'):
            parts.append(f"Supplier: {invoice_data['supplier']}")

        if invoice_data.get('invoice_number'):
            parts.append(f"Invoice Number: {invoice_data['invoice_number']}")

        if invoice_data.get('invoice_date'):
            parts.append(f"Date: {invoice_data['invoice_date']}")

        if invoice_data.get('invoice_value'):
            currency = invoice_data.get('currency', 'RON')
            parts.append(f"Amount: {invoice_data['invoice_value']} {currency}")

        if invoice_data.get('allocated_company'):
            parts.append(f"Company: {invoice_data['allocated_company']}")

        if invoice_data.get('allocated_brand'):
            parts.append(f"Brand: {invoice_data['allocated_brand']}")

        if invoice_data.get('allocated_department'):
            parts.append(f"Department: {invoice_data['allocated_department']}")

        if invoice_data.get('allocated_subdepartment'):
            parts.append(f"Subdepartment: {invoice_data['allocated_subdepartment']}")

        if invoice_data.get('type'):
            parts.append(f"Type: {invoice_data['type']}")

        if invoice_data.get('status'):
            parts.append(f"Status: {invoice_data['status']}")

        if invoice_data.get('payment_status'):
            parts.append(f"Payment: {invoice_data['payment_status']}")

        # Additional context
        if invoice_data.get('supplier_vat'):
            parts.append(f"Supplier VAT: {invoice_data['supplier_vat']}")

        if invoice_data.get('customer_vat'):
            parts.append(f"Customer VAT: {invoice_data['customer_vat']}")

        return "\n".join(parts)

    def _create_snippet(self, content: str, max_length: int = 300) -> str:
        """Create a snippet from content."""
        if len(content) <= max_length:
            return content

        # Try to break at sentence
        snippet = content[:max_length]
        last_period = snippet.rfind('.')
        if last_period > max_length // 2:
            return snippet[:last_period + 1]

        # Break at word
        last_space = snippet.rfind(' ')
        if last_space > 0:
            return snippet[:last_space] + "..."

        return snippet + "..."

    # ============== Generic Index Helper ==============

    def _index_document(
        self,
        source_type: RAGSourceType,
        source_id: int,
        source_table: str,
        content: str,
        metadata: Dict[str, Any],
        company_id: Optional[int] = None,
    ) -> ServiceResult:
        """
        Generic document indexing — hash check, upsert, embed.

        Used by all source-type-specific index methods to avoid duplication.
        """
        try:
            content_hash = self.embedding_service.compute_content_hash(content)

            existing = self.document_repo.get_by_source(source_type, source_id)
            if existing and existing.content_hash == content_hash:
                return ServiceResult(success=True, data=existing)

            embedding = None
            if self._has_embeddings:
                try:
                    embedding = self.embedding_service.generate_embedding(content)
                except Exception as e:
                    logger.warning(f"Failed to generate embedding for {source_type.value} {source_id}: {e}")

            document = RAGDocument(
                source_type=source_type,
                source_id=source_id,
                source_table=source_table,
                content=content,
                content_hash=content_hash,
                embedding=embedding,
                metadata=metadata,
                company_id=company_id,
            )

            if existing:
                if embedding:
                    self.document_repo.update_embedding(existing.id, embedding, content_hash)
                document.id = existing.id
            else:
                document = self.document_repo.create(document)

            return ServiceResult(success=True, data=document)

        except Exception as e:
            logger.error(f"Failed to index {source_type.value} {source_id}: {e}")
            return ServiceResult(success=False, error=str(e))

    def _lookup_company_id(self, company_name: Optional[str]) -> Optional[int]:
        """Look up company ID from company name."""
        if not company_name:
            return None
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute("SELECT id FROM companies WHERE company = %s", (company_name,))
            row = cursor.fetchone()
            return row['id'] if row else None
        finally:
            release_db(conn)

    # ============== Company Indexing ==============

    def _fetch_company_data(self, company_id: int) -> Optional[Dict]:
        """Fetch company data from database."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute("SELECT * FROM companies WHERE id = %s", (company_id,))
            return cursor.fetchone()
        finally:
            release_db(conn)

    def _build_company_content(self, data: Dict) -> str:
        """Build searchable content from company data."""
        parts = []
        if data.get('company'):
            parts.append(f"Company: {data['company']}")
        if data.get('vat'):
            parts.append(f"VAT/CUI: {data['vat']}")
        if data.get('brands'):
            parts.append(f"Brands: {data['brands']}")
        return "\n".join(parts)

    def index_company(self, company_id: int) -> ServiceResult:
        """Index a company for RAG search."""
        data = self._fetch_company_data(company_id)
        if not data:
            return ServiceResult(success=False, error="Company not found")

        content = self._build_company_content(data)
        metadata = {
            'name': data.get('company'),
            'cui': data.get('vat'),
        }
        return self._index_document(
            RAGSourceType.COMPANY, company_id, 'companies', content, metadata, company_id
        )

    def index_companies_batch(self, limit: int = 500) -> ServiceResult:
        """Batch index companies."""
        try:
            conn = get_db()
            try:
                cursor = get_cursor(conn)
                cursor.execute("""
                    SELECT c.id FROM companies c
                    LEFT JOIN ai_agent.rag_documents r
                        ON r.source_type = 'company' AND r.source_id = c.id AND r.is_active = TRUE
                    WHERE r.id IS NULL
                    LIMIT %s
                """, (limit,))
                rows = cursor.fetchall()
            finally:
                release_db(conn)

            indexed = 0
            for row in rows:
                if self.index_company(row['id']).success:
                    indexed += 1

            logger.info(f"Batch indexed {indexed} companies")
            return ServiceResult(success=True, data={'indexed': indexed})
        except Exception as e:
            logger.error(f"Company batch indexing failed: {e}")
            return ServiceResult(success=False, error=str(e))

    # ============== Department Indexing ==============

    def _fetch_department_data(self, dept_id: int) -> Optional[Dict]:
        """Fetch department structure data from database."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute("SELECT * FROM department_structure WHERE id = %s", (dept_id,))
            return cursor.fetchone()
        finally:
            release_db(conn)

    def _build_department_content(self, data: Dict) -> str:
        """Build searchable content from department data."""
        parts = []
        if data.get('department'):
            parts.append(f"Department: {data['department']}")
        if data.get('subdepartment'):
            parts.append(f"Subdepartment: {data['subdepartment']}")
        if data.get('company'):
            parts.append(f"Company: {data['company']}")
        if data.get('brand'):
            parts.append(f"Brand: {data['brand']}")
        if data.get('manager'):
            parts.append(f"Manager: {data['manager']}")
        return "\n".join(parts)

    def index_department(self, dept_id: int) -> ServiceResult:
        """Index a department for RAG search."""
        data = self._fetch_department_data(dept_id)
        if not data:
            return ServiceResult(success=False, error="Department not found")

        content = self._build_department_content(data)
        metadata = {
            'name': data.get('department'),
            'subdepartment': data.get('subdepartment'),
            'company': data.get('company'),
            'brand': data.get('brand'),
        }
        company_id = self._lookup_company_id(data.get('company'))
        return self._index_document(
            RAGSourceType.DEPARTMENT, dept_id, 'department_structure', content, metadata, company_id
        )

    def index_departments_batch(self, limit: int = 500) -> ServiceResult:
        """Batch index departments."""
        try:
            conn = get_db()
            try:
                cursor = get_cursor(conn)
                cursor.execute("""
                    SELECT d.id FROM department_structure d
                    LEFT JOIN ai_agent.rag_documents r
                        ON r.source_type = 'department' AND r.source_id = d.id AND r.is_active = TRUE
                    WHERE r.id IS NULL
                    LIMIT %s
                """, (limit,))
                rows = cursor.fetchall()
            finally:
                release_db(conn)

            indexed = 0
            for row in rows:
                if self.index_department(row['id']).success:
                    indexed += 1

            logger.info(f"Batch indexed {indexed} departments")
            return ServiceResult(success=True, data={'indexed': indexed})
        except Exception as e:
            logger.error(f"Department batch indexing failed: {e}")
            return ServiceResult(success=False, error=str(e))

    # ============== Employee Indexing ==============

    def _fetch_employee_data(self, user_id: int) -> Optional[Dict]:
        """Fetch employee/user data from database."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute("""
                SELECT u.*, r.name as role_name
                FROM users u
                LEFT JOIN roles r ON r.id = u.role_id
                WHERE u.id = %s AND u.is_active = TRUE
            """, (user_id,))
            return cursor.fetchone()
        finally:
            release_db(conn)

    def _build_employee_content(self, data: Dict) -> str:
        """Build searchable content from employee data."""
        parts = []
        if data.get('name'):
            parts.append(f"Employee: {data['name']}")
        if data.get('email'):
            parts.append(f"Email: {data['email']}")
        if data.get('phone'):
            parts.append(f"Phone: {data['phone']}")
        if data.get('company'):
            parts.append(f"Company: {data['company']}")
        if data.get('department'):
            parts.append(f"Department: {data['department']}")
        if data.get('subdepartment'):
            parts.append(f"Subdepartment: {data['subdepartment']}")
        if data.get('brand'):
            parts.append(f"Brand: {data['brand']}")
        if data.get('role_name'):
            parts.append(f"Role: {data['role_name']}")
        return "\n".join(parts)

    def index_employee(self, user_id: int) -> ServiceResult:
        """Index an employee for RAG search."""
        data = self._fetch_employee_data(user_id)
        if not data:
            return ServiceResult(success=False, error="Employee not found")

        content = self._build_employee_content(data)
        metadata = {
            'name': data.get('name'),
            'department': data.get('department'),
            'company': data.get('company'),
            'role': data.get('role_name'),
        }
        company_id = self._lookup_company_id(data.get('company'))
        return self._index_document(
            RAGSourceType.EMPLOYEE, user_id, 'users', content, metadata, company_id
        )

    def index_employees_batch(self, limit: int = 500) -> ServiceResult:
        """Batch index employees."""
        try:
            conn = get_db()
            try:
                cursor = get_cursor(conn)
                cursor.execute("""
                    SELECT u.id FROM users u
                    LEFT JOIN ai_agent.rag_documents r
                        ON r.source_type = 'employee' AND r.source_id = u.id AND r.is_active = TRUE
                    WHERE u.is_active = TRUE AND r.id IS NULL
                    LIMIT %s
                """, (limit,))
                rows = cursor.fetchall()
            finally:
                release_db(conn)

            indexed = 0
            for row in rows:
                if self.index_employee(row['id']).success:
                    indexed += 1

            logger.info(f"Batch indexed {indexed} employees")
            return ServiceResult(success=True, data={'indexed': indexed})
        except Exception as e:
            logger.error(f"Employee batch indexing failed: {e}")
            return ServiceResult(success=False, error=str(e))

    # ============== Bank Transaction Indexing ==============

    def _fetch_transaction_data(self, txn_id: int) -> Optional[Dict]:
        """Fetch bank transaction data from database."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute("""
                SELECT t.*, c.id as company_id_lookup
                FROM bank_statement_transactions t
                LEFT JOIN companies c ON c.vat = t.company_cui
                WHERE t.id = %s AND t.merged_into_id IS NULL
            """, (txn_id,))
            return cursor.fetchone()
        finally:
            release_db(conn)

    def _build_transaction_content(self, data: Dict) -> str:
        """Build searchable content from transaction data."""
        parts = []
        if data.get('description'):
            parts.append(f"Bank Transaction: {data['description']}")
        if data.get('vendor_name'):
            parts.append(f"Vendor: {data['vendor_name']}")
        if data.get('matched_supplier'):
            parts.append(f"Matched Supplier: {data['matched_supplier']}")
        if data.get('amount') is not None:
            currency = data.get('currency', 'RON')
            parts.append(f"Amount: {data['amount']} {currency}")
        if data.get('transaction_date'):
            parts.append(f"Date: {data['transaction_date']}")
        if data.get('company_name'):
            parts.append(f"Company: {data['company_name']}")
        if data.get('account_number'):
            parts.append(f"Account: {data['account_number']}")
        if data.get('status'):
            parts.append(f"Status: {data['status']}")
        return "\n".join(parts)

    def index_transaction(self, txn_id: int) -> ServiceResult:
        """Index a bank transaction for RAG search."""
        data = self._fetch_transaction_data(txn_id)
        if not data:
            return ServiceResult(success=False, error="Transaction not found")

        content = self._build_transaction_content(data)
        metadata = {
            'vendor_name': data.get('vendor_name') or data.get('matched_supplier'),
            'amount': str(data.get('amount', '')),
            'currency': data.get('currency', 'RON'),
            'date': str(data.get('transaction_date', '')),
            'status': data.get('status'),
        }
        company_id = data.get('company_id_lookup')
        return self._index_document(
            RAGSourceType.TRANSACTION, txn_id, 'bank_statement_transactions', content, metadata, company_id
        )

    def index_transactions_batch(self, limit: int = 500) -> ServiceResult:
        """Batch index bank transactions."""
        try:
            conn = get_db()
            try:
                cursor = get_cursor(conn)
                cursor.execute("""
                    SELECT t.id FROM bank_statement_transactions t
                    LEFT JOIN ai_agent.rag_documents r
                        ON r.source_type = 'transaction' AND r.source_id = t.id AND r.is_active = TRUE
                    WHERE t.merged_into_id IS NULL AND r.id IS NULL
                    LIMIT %s
                """, (limit,))
                rows = cursor.fetchall()
            finally:
                release_db(conn)

            indexed = 0
            for row in rows:
                if self.index_transaction(row['id']).success:
                    indexed += 1

            logger.info(f"Batch indexed {indexed} transactions")
            return ServiceResult(success=True, data={'indexed': indexed})
        except Exception as e:
            logger.error(f"Transaction batch indexing failed: {e}")
            return ServiceResult(success=False, error=str(e))

    # ============== e-Factura Indexing ==============

    def _fetch_efactura_data(self, ef_id: int) -> Optional[Dict]:
        """Fetch e-Factura invoice data from database."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute("""
                SELECT * FROM efactura_invoices
                WHERE id = %s AND deleted_at IS NULL AND ignored = FALSE
            """, (ef_id,))
            return cursor.fetchone()
        finally:
            release_db(conn)

    def _build_efactura_content(self, data: Dict) -> str:
        """Build searchable content from e-Factura data."""
        parts = []
        if data.get('invoice_number'):
            series = data.get('invoice_series', '')
            num = data.get('invoice_number')
            parts.append(f"e-Factura Invoice: {series}{num}" if series else f"e-Factura Invoice: {num}")
        if data.get('partner_name'):
            parts.append(f"Partner: {data['partner_name']}")
        if data.get('partner_cif'):
            parts.append(f"Partner CIF: {data['partner_cif']}")
        if data.get('direction'):
            parts.append(f"Direction: {data['direction']}")
        if data.get('total_amount') is not None:
            currency = data.get('currency', 'RON')
            parts.append(f"Amount: {data['total_amount']} {currency}")
        if data.get('total_vat') is not None:
            parts.append(f"VAT: {data['total_vat']}")
        if data.get('issue_date'):
            parts.append(f"Date: {data['issue_date']}")
        if data.get('status'):
            parts.append(f"Status: {data['status']}")
        if data.get('cif_owner'):
            parts.append(f"Owner CIF: {data['cif_owner']}")
        return "\n".join(parts)

    def index_efactura(self, ef_id: int) -> ServiceResult:
        """Index an e-Factura invoice for RAG search."""
        data = self._fetch_efactura_data(ef_id)
        if not data:
            return ServiceResult(success=False, error="e-Factura invoice not found")

        content = self._build_efactura_content(data)
        metadata = {
            'invoice_number': data.get('invoice_number'),
            'partner_name': data.get('partner_name'),
            'amount': str(data.get('total_amount', '')),
            'currency': data.get('currency', 'RON'),
            'date': str(data.get('issue_date', '')),
            'direction': data.get('direction'),
        }
        return self._index_document(
            RAGSourceType.EFACTURA, ef_id, 'efactura_invoices', content, metadata, data.get('company_id')
        )

    def index_efactura_batch(self, limit: int = 500) -> ServiceResult:
        """Batch index e-Factura invoices."""
        try:
            conn = get_db()
            try:
                cursor = get_cursor(conn)
                cursor.execute("""
                    SELECT e.id FROM efactura_invoices e
                    LEFT JOIN ai_agent.rag_documents r
                        ON r.source_type = 'efactura' AND r.source_id = e.id AND r.is_active = TRUE
                    WHERE e.deleted_at IS NULL AND e.ignored = FALSE AND r.id IS NULL
                    LIMIT %s
                """, (limit,))
                rows = cursor.fetchall()
            finally:
                release_db(conn)

            indexed = 0
            for row in rows:
                if self.index_efactura(row['id']).success:
                    indexed += 1

            logger.info(f"Batch indexed {indexed} e-Factura invoices")
            return ServiceResult(success=True, data={'indexed': indexed})
        except Exception as e:
            logger.error(f"e-Factura batch indexing failed: {e}")
            return ServiceResult(success=False, error=str(e))

    # ============== HR Event Indexing ==============

    def _fetch_event_data(self, event_id: int) -> Optional[Dict]:
        """Fetch HR event data with aggregated bonus info."""
        conn = get_db()
        try:
            cursor = get_cursor(conn)
            cursor.execute("""
                SELECT e.*,
                       COUNT(b.id) as bonus_count,
                       COALESCE(SUM(b.bonus_net), 0) as total_bonus_net
                FROM hr.events e
                LEFT JOIN hr.event_bonuses b ON b.event_id = e.id
                WHERE e.id = %s
                GROUP BY e.id
            """, (event_id,))
            return cursor.fetchone()
        finally:
            release_db(conn)

    def _build_event_content(self, data: Dict) -> str:
        """Build searchable content from HR event data."""
        parts = []
        if data.get('name'):
            parts.append(f"HR Event: {data['name']}")
        if data.get('company'):
            parts.append(f"Company: {data['company']}")
        if data.get('brand'):
            parts.append(f"Brand: {data['brand']}")
        if data.get('start_date'):
            parts.append(f"Start: {data['start_date']}")
        if data.get('end_date'):
            parts.append(f"End: {data['end_date']}")
        if data.get('description'):
            parts.append(f"Description: {data['description']}")
        if data.get('bonus_count'):
            parts.append(f"Bonuses: {data['bonus_count']} entries")
        if data.get('total_bonus_net'):
            parts.append(f"Total Bonus Net: {data['total_bonus_net']} RON")
        return "\n".join(parts)

    def index_event(self, event_id: int) -> ServiceResult:
        """Index an HR event for RAG search."""
        data = self._fetch_event_data(event_id)
        if not data:
            return ServiceResult(success=False, error="HR event not found")

        content = self._build_event_content(data)
        metadata = {
            'name': data.get('name'),
            'company': data.get('company'),
            'brand': data.get('brand'),
            'start_date': str(data.get('start_date', '')),
            'end_date': str(data.get('end_date', '')),
            'bonus_count': data.get('bonus_count', 0),
        }
        company_id = self._lookup_company_id(data.get('company'))
        return self._index_document(
            RAGSourceType.EVENT, event_id, 'hr.events', content, metadata, company_id
        )

    def index_events_batch(self, limit: int = 500) -> ServiceResult:
        """Batch index HR events."""
        try:
            conn = get_db()
            try:
                cursor = get_cursor(conn)
                cursor.execute("""
                    SELECT e.id FROM hr.events e
                    LEFT JOIN ai_agent.rag_documents r
                        ON r.source_type = 'event' AND r.source_id = e.id AND r.is_active = TRUE
                    WHERE r.id IS NULL
                    LIMIT %s
                """, (limit,))
                rows = cursor.fetchall()
            finally:
                release_db(conn)

            indexed = 0
            for row in rows:
                if self.index_event(row['id']).success:
                    indexed += 1

            logger.info(f"Batch indexed {indexed} HR events")
            return ServiceResult(success=True, data={'indexed': indexed})
        except Exception as e:
            logger.error(f"HR event batch indexing failed: {e}")
            return ServiceResult(success=False, error=str(e))

    # ============== Orchestration ==============

    def index_all_sources(self, limit: int = 500) -> ServiceResult:
        """Reindex all source types."""
        results = {}
        total = 0

        batch_methods = [
            ('invoices', self.index_invoices_batch),
            ('companies', self.index_companies_batch),
            ('departments', self.index_departments_batch),
            ('employees', self.index_employees_batch),
            ('transactions', self.index_transactions_batch),
            ('efactura', self.index_efactura_batch),
            ('events', self.index_events_batch),
        ]

        for name, method in batch_methods:
            try:
                result = method(limit=limit)
                count = result.data.get('indexed', 0) if result.success else 0
                results[name] = count
                total += count
            except Exception as e:
                logger.error(f"Failed to index {name}: {e}")
                results[name] = 0

        logger.info(f"Total indexed across all sources: {total}")
        return ServiceResult(success=True, data={'by_source': results, 'total': total})
