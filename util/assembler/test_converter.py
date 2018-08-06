import unittest
from unittest import TestCase
from converter import CoeConverter
from io import StringIO


class TestCoeConverter(TestCase):
    def test_empty(self):
        f = StringIO()
        converter = CoeConverter()
        converter.do_convert(f)
        f.seek(0)
        self.assertEqual(
            'memory_initialization_radix=16;\nmemory_initialization_vector=\n;',
            f.read().lower())

    def test_normal_1(self):
        f = StringIO()
        converter = CoeConverter()
        converter.write(b'\x34\x01\x12\x34\xAC\x01\x00\x00\x34\x02\x12\x34\x34\x01\x00\x00')
        converter.do_convert(f)
        f.seek(0)
        self.assertEqual(
            'memory_initialization_radix=16;\nmemory_initialization_vector=\n'
            '34011234\n'
            'ac010000\n'
            '34021234\n'
            '34010000\n'
            ';',
            f.read().lower()
        )

    def test_normal_2(self):
        f = StringIO()
        converter = CoeConverter()
        converter.write(b'\x34\x01\x12\x34\xAC\x01\x00\x00\x34\x02\x12\x34\x34\x01')
        converter.do_convert(f)
        f.seek(0)
        self.assertEqual(
            'memory_initialization_radix=16;\nmemory_initialization_vector=\n'
            '34011234\n'
            'ac010000\n'
            '34021234\n'
            '3401\n'
            ';',
            f.read().lower()
        )