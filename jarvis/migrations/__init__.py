"""Database migrations package.

Contains schema initialization and seed data for the JARVIS database.
"""
from .init_schema import create_schema

__all__ = ['create_schema']
