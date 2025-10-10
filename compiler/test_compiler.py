"""
Test Suite for C++ Compiler
This script runs all example programs to test the compiler functionality.
"""

import sys
import os
from pathlib import Path

# Add the parent directory to path so we can import the compiler modules
sys.path.insert(0, str(Path(__file__).parent))

from main import CppCompiler

def run_test_file(compiler, test_file):
    """Run a single test file"""
    print(f"\n{'='*60}")
    print(f"Testing: {test_file}")
    print(f"{'='*60}")
    
    try:
        success = compiler.compile_file(test_file)
        if success:
            print(f"✅ {test_file} - PASSED")
            return True
        else:
            print(f"❌ {test_file} - FAILED")
            return False
    except Exception as e:
        print(f"❌ {test_file} - ERROR: {e}")
        return False

def main():
    """Run all tests"""
    print("C++ Compiler Test Suite")
    print("=" * 60)
    
    # Initialize compiler
    compiler = CppCompiler()
    compiler.verbose = False
    
    # Find all test files
    examples_dir = Path(__file__).parent / "examples"
    
    if not examples_dir.exists():
        print("Examples directory not found!")
        return
    
    test_files = list(examples_dir.glob("*.cpp"))
    
    if not test_files:
        print("No test files found in examples directory!")
        return
    
    # Run tests
    passed = 0
    total = len(test_files)
    
    for test_file in sorted(test_files):
        if run_test_file(compiler, str(test_file)):
            passed += 1
    
    # Summary
    print(f"\n{'='*60}")
    print(f"Test Results: {passed}/{total} tests passed")
    print(f"Success rate: {(passed/total)*100:.1f}%")
    
    if passed == total:
        print("🎉 All tests passed!")
        return 0
    else:
        print(f"⚠️  {total - passed} test(s) failed")
        return 1

if __name__ == "__main__":
    sys.exit(main())