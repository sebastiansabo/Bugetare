export interface Conversation {
  id: number
  title: string
  status: 'active' | 'archived' | 'deleted'
  message_count: number
  total_tokens: number
  total_cost: string
  created_at: string
  updated_at: string
}

export interface Message {
  id: number
  role: 'user' | 'assistant'
  content: string
  input_tokens: number
  output_tokens: number
  cost: string
  response_time_ms: number
  created_at: string
}

export interface ConversationDetail extends Conversation {
  messages: Message[]
}

export interface ChatResponse {
  message: Message
  rag_sources: RagSource[]
  tokens_used: number
  cost: string
  response_time_ms: number
}

export interface RagSource {
  doc_id: number
  snippet: string
  source_type: string
  score: number
}

export interface StreamDoneEvent {
  message_id: number
  tokens_used: number
  cost: string
  response_time_ms: number
  rag_sources: RagSource[]
}

export interface Model {
  id: number
  provider: string
  model_name: string
  display_name: string
  cost_per_1k_input: string
  cost_per_1k_output: string
  max_tokens: number
  is_default: boolean
}
