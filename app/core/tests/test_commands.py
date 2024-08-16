"""
Test custom Django management commands.
"""
from unittest.mock import patch

from psycopg2 import OperationalError as Psycopg2Error

from django.core.management import call_command
from django.db.utils import OperationalError
from django.test import SimpleTestCase


@patch('core.management.commands.wait_for_db.Command.check')
class CommandTests(SimpleTestCase):

    def test_wait_for_db_ready(self, patched_check):
        patched_check.return_value = True

        call_command('wait_for_db')

        patched_check.assert_called_once_with(databases=['default'])

    @patch('time.sleep')
    # ważne - najpierw w metodzie pobieramy wewnętrzny patch pozniej zewnętrzny
    def test_wait_for_db_delay(self, patched_sleep, patched_check):
        # to są przykładowe wartości - symulacja 2 razy wywołujemt Psycopg2Error i 3 razy OperationalError # noqa
        # \ pozwala na przeniesienie kontynuacji operacji matematycznych na następną linie # noqa
        # patched_check.side_effect = [Psycopg2Error] * 2 + [OperationalError] * 3 + [True] # noqa
        patched_check.side_effect = [Psycopg2Error] * 2 + \
            [OperationalError] * 3 + [True]

        call_command('wait_for_db')

        self.assertEqual(patched_check.call_count, 6)
        patched_check.assert_called_with(databases=["default"])
