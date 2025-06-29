"""add_link_table

Revision ID: e92a133a3c87
Revises: 96428d8c7193
Create Date: 2025-06-21 20:14:40.900485

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'e92a133a3c87'
down_revision: Union[str, None] = '96428d8c7193'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    # Create link table
    op.create_table('link',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('title', sa.String(length=100), nullable=False, comment='链接标题'),
        sa.Column('url', sa.String(length=255), nullable=False, comment='链接地址'),
        sa.Column('description', sa.Text(), nullable=True, comment='链接描述'),
        sa.Column('is_active', sa.Boolean(), nullable=True, comment='是否启用'),
        sa.Column('sort_order', sa.Integer(), nullable=True, comment='排序权重，数字越大越靠前'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=True),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_link_id'), 'link', ['id'], unique=False)


def downgrade() -> None:
    """Downgrade schema."""
    # Drop link table
    op.drop_index(op.f('ix_link_id'), table_name='link')
    op.drop_table('link')
