"""add_multilevel_category_support

Revision ID: 48e5cfbd4e2c
Revises: b2c232f84020
Create Date: 2025-06-27 17:56:19.872057

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '48e5cfbd4e2c'
down_revision: Union[str, None] = 'b2c232f84020'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('category', sa.Column('parent_id', sa.Integer(), nullable=True))
    op.add_column('category', sa.Column('level', sa.Integer(), nullable=False))
    op.add_column('category', sa.Column('sort_order', sa.Integer(), nullable=False))
    op.create_index(op.f('ix_category_parent_id'), 'category', ['parent_id'], unique=False)
    op.create_foreign_key(None, 'category', 'category', ['parent_id'], ['id'])
    # ### end Alembic commands ###


def downgrade() -> None:
    """Downgrade schema."""
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_constraint(None, 'category', type_='foreignkey')
    op.drop_index(op.f('ix_category_parent_id'), table_name='category')
    op.drop_column('category', 'sort_order')
    op.drop_column('category', 'level')
    op.drop_column('category', 'parent_id')
    # ### end Alembic commands ###
