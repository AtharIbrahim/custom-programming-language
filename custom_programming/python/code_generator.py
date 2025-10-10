"""
C++ Code Generator
This module generates Python code that can be executed to simulate the C++ program behavior.
Since creating a full assembly/machine code generator is complex, we'll generate Python code
that maintains C++ semantics but can be executed direct            #             # Generate the cout calls - use std.cout for std::cout
            cout_obj = \"std.cout\" if current.name == 'std::cout' else \"cout\"
            for arg in args:
                arg_code = self.generate_expression(arg)
                # Convert std:: to std. in argument expressions
                if 'std::' in arg_code:
                    arg_code = arg_code.replace('std::', 'std.')
                self.emit(f\"{cout_obj}.__lshift__({arg_code})\")ate the cout calls - use std.cout for std::cout
            cout_obj = \"std.cout\" if current.n    def generate_identifier(self, node: Identifier) -> str:
        \"\"\"Generate code for an identifier\"\"\"
        # Handle std:: qualified names
        if node.name.startswith('std::'):
            return node.name.replace('::', '.')
        return node.name == 'std::cout' else \"cout\"
            for arg in args:
                arg_code = self.generate_expression(arg)
                # Convert std:: to std. in argument expressions
                arg_code = arg_code.replace('std::', 'std.')
                self.emit(f\"{cout_obj}.__lshift__({arg_code})\")"""

import sys
from typing import Dict, List, Optional, Any, Union
from parser import *
from semantic_analyzer import SemanticAnalyzer, Symbol, Scope

class CodeGenerator:
    """Generates executable Python code from C++ AST"""
    
    def __init__(self, semantic_analyzer: SemanticAnalyzer):
        self.analyzer = semantic_analyzer
        self.output = []
        self.indent_level = 0
        self.temp_var_count = 0
        self.in_main_function = False
        
        # Runtime environment for execution
        self.runtime_globals = {
            'cout': self,  # cout object
            'endl': '\n',
            '__return_value': None,
            '__return_called': False,
        }
        
        # Generated code storage
        self.generated_code = ""
    
    def emit(self, code: str):
        """Emit a line of code with proper indentation"""
        indent = "    " * self.indent_level
        self.output.append(indent + code)
    
    def emit_raw(self, code: str):
        """Emit code without indentation"""
        self.output.append(code)
    
    def increase_indent(self):
        """Increase indentation level"""
        self.indent_level += 1
    
    def decrease_indent(self):
        """Decrease indentation level"""
        self.indent_level = max(0, self.indent_level - 1)
    
    def get_temp_var(self) -> str:
        """Generate a temporary variable name"""
        name = f"__temp_{self.temp_var_count}"
        self.temp_var_count += 1
        return name
    
    def generate(self, ast: Program) -> str:
        """Generate code from AST"""
        # Emit header
        self.emit_raw("# Generated C++ code (Python implementation)")
        self.emit_raw("import sys")
        self.emit_raw("import math")
        self.emit_raw("")
        
        # Emit runtime support
        self.emit_runtime_support()
        
        # Generate main code
        self.generate_program(ast)
        
        # Add global declarations at the end
        self.emit_raw("")
        self.emit_raw("# Execute main if this is the main module")
        
        # Join all output
        self.generated_code = "\n".join(self.output)
        return self.generated_code
    
    def emit_runtime_support(self):
        """Emit runtime support functions"""
        self.emit_raw("# Runtime support")
        self.emit_raw("class CppRuntime:")
        self.emit_raw("    def __init__(self):")
        self.emit_raw("        self.output_buffer = []")
        self.emit_raw("        self.return_value = 0")
        self.emit_raw("        self.return_called = False")
        self.emit_raw("")
        self.emit_raw("    def cout_output(self, value):")
        self.emit_raw("        if isinstance(value, str) and value.startswith('\"') and value.endswith('\"'):")
        self.emit_raw("            value = value[1:-1]  # Remove quotes")
        self.emit_raw("        self.output_buffer.append(str(value))")
        self.emit_raw("        return self")
        self.emit_raw("")
        self.emit_raw("    def cout_endl(self):")
        self.emit_raw("        self.output_buffer.append('\\n')")
        self.emit_raw("        return self")
        self.emit_raw("")
        self.emit_raw("    def get_output(self):")
        self.emit_raw("        return ''.join(self.output_buffer)")
        self.emit_raw("")
        self.emit_raw("    def set_return(self, value):")
        self.emit_raw("        self.return_value = value")
        self.emit_raw("        self.return_called = True")
        self.emit_raw("")
        self.emit_raw("# Global runtime instance")
        self.emit_raw("cpp_runtime = CppRuntime()")
        self.emit_raw("cout = cpp_runtime")
        self.emit_raw("endl = '\\n'")
        self.emit_raw("")
        self.emit_raw("# std namespace simulation")
        self.emit_raw("class StdNamespace:")
        self.emit_raw("    def __init__(self):")
        self.emit_raw("        self.cout = cpp_runtime")
        self.emit_raw("        self.endl = '\\n'")
        self.emit_raw("")
        self.emit_raw("std = StdNamespace()")
        self.emit_raw("")
        
        # Operator overloading for cout
        self.emit_raw("def __lshift__(self, other):")
        self.emit_raw("    if other == endl or str(other) == '\\n':")
        self.emit_raw("        return self.cout_endl()")
        self.emit_raw("    else:")
        self.emit_raw("        return self.cout_output(other)")
        self.emit_raw("")
        self.emit_raw("CppRuntime.__lshift__ = __lshift__")
        self.emit_raw("")
        
        # Helper function for cout operations
        self.emit_raw("def cout_print(*args):")
        self.emit_raw("    result = cpp_runtime")
        self.emit_raw("    for arg in args:")
        self.emit_raw("        result = result.__lshift__(arg)")
        self.emit_raw("    return result")
        self.emit_raw("")
    
    def generate_program(self, node: Program):
        """Generate code for the entire program"""
        # First pass: declare all functions
        for declaration in node.declarations:
            if isinstance(declaration, FunctionDeclaration):
                self.generate_function_declaration(declaration)
            elif isinstance(declaration, ClassDeclaration):
                # Class declarations generate no runtime code in this simplified model
                self.emit_raw(f"# Skipping class {declaration.name} declaration (no runtime effect)")
        
        # Generate main execution
        self.emit_raw("")
        self.emit_raw("# Main execution")
        self.emit_raw("if __name__ == '__main__':")
        self.increase_indent()
        
        # Look for main function
        main_found = False
        for declaration in node.declarations:
            if isinstance(declaration, FunctionDeclaration) and declaration.name == 'main':
                self.emit("try:")
                self.increase_indent()
                self.emit("exit_code = main()")
                self.emit("print(cpp_runtime.get_output(), end='')")
                self.emit("sys.exit(exit_code if exit_code is not None else 0)")
                self.decrease_indent()
                self.emit("except SystemExit:")
                self.increase_indent()
                self.emit("print(cpp_runtime.get_output(), end='')")
                self.emit("sys.exit(cpp_runtime.return_value)")
                self.decrease_indent()
                main_found = True
                break
        
        if not main_found:
            self.emit("print('No main function found')")
            self.emit("sys.exit(1)")
        
        self.decrease_indent()
    
    def generate_function_declaration(self, node: FunctionDeclaration):
        """Generate code for a function declaration"""
        # Function signature
        param_names = [param_name for _, param_name in node.parameters]
        param_str = ", ".join(param_names)
        
        self.emit_raw(f"def {node.name}({param_str}):")
        self.increase_indent()
        
        # Mark if we're in main function
        if node.name == 'main':
            self.in_main_function = True
        
        # Initialize local variables (will be handled in variable declarations)
        
        # Generate function body
        self.generate_statement(node.body)
        
        # Add default return if needed
        if node.return_type.name == 'void':
            self.emit("return None")
        elif node.return_type.name == 'int' and node.name == 'main':
            self.emit("return 0  # Default return for main")
        else:
            self.emit(f"return {self.get_default_value(node.return_type.name)}")
        
        self.decrease_indent()
        self.emit_raw("")
        
        if node.name == 'main':
            self.in_main_function = False
    
    def get_default_value(self, type_name: str) -> str:
        """Get default value for a type"""
        defaults = {
            'int': '0',
            'float': '0.0',
            'double': '0.0',
            'char': "''",
            'bool': 'False',
            'string': '""',
        }
        return defaults.get(type_name, 'None')
    
    def generate_statement(self, node: Statement):
        """Generate code for a statement"""
        if isinstance(node, VariableDeclaration):
            self.generate_variable_declaration(node)
        elif isinstance(node, ExpressionStatement):
            self.generate_expression_statement(node)
        elif isinstance(node, Block):
            self.generate_block(node)
        elif isinstance(node, IfStatement):
            self.generate_if_statement(node)
        elif isinstance(node, WhileStatement):
            self.generate_while_statement(node)
        elif isinstance(node, ForStatement):
            self.generate_for_statement(node)
        elif isinstance(node, ReturnStatement):
            self.generate_return_statement(node)
        else:
            self.emit(f"# Unsupported statement: {type(node)}")
    
    def generate_variable_declaration(self, node: VariableDeclaration):
        """Generate code for a variable declaration"""
        if node.initializer:
            init_code = self.generate_expression(node.initializer)
            self.emit(f"{node.name} = {init_code}")
        else:
            default_value = self.get_default_value(node.var_type.name)
            self.emit(f"{node.name} = {default_value}")
    
    def generate_expression_statement(self, node: ExpressionStatement):
        """Generate code for an expression statement"""
        if isinstance(node.expression, BinaryOperation) and node.expression.operator == '<<':
            # Handle cout << expressions specially
            self.generate_cout_chain(node.expression)
        else:
            expr_code = self.generate_expression(node.expression)
            self.emit(f"{expr_code}")
    
    def generate_cout_chain(self, node: Expression):
        """Generate code for cout << chain"""
        # Collect all the arguments in the cout chain
        args = []
        current = node
        
        while isinstance(current, BinaryOperation) and current.operator == '<<':
            args.append(current.right)
            current = current.left
        
        # Check if it starts with cout or std::cout
        if isinstance(current, Identifier) and (current.name == 'cout' or current.name == 'std::cout'):
            # Reverse the args list since we collected them backwards
            args.reverse()
            
            # Generate the cout calls - use std.cout for std::cout
            cout_obj = "std.cout" if current.name == 'std::cout' else "cout"
            for arg in args:
                arg_code = self.generate_expression(arg)
                self.emit(f"{cout_obj}.__lshift__({arg_code})")
        else:
            # Not a cout chain, generate normally
            expr_code = self.generate_expression(node)
            self.emit(f"{expr_code}")
    
    def generate_block(self, node: Block):
        """Generate code for a block statement"""
        for statement in node.statements:
            self.generate_statement(statement)
    
    def generate_if_statement(self, node: IfStatement):
        """Generate code for an if statement"""
        condition_code = self.generate_expression(node.condition)
        self.emit(f"if {condition_code}:")
        self.increase_indent()
        self.generate_statement(node.then_stmt)
        self.decrease_indent()
        
        if node.else_stmt:
            self.emit("else:")
            self.increase_indent()
            self.generate_statement(node.else_stmt)
            self.decrease_indent()
    
    def generate_while_statement(self, node: WhileStatement):
        """Generate code for a while statement"""
        condition_code = self.generate_expression(node.condition)
        self.emit(f"while {condition_code}:")
        self.increase_indent()
        self.generate_statement(node.body)
        self.decrease_indent()
    
    def generate_for_statement(self, node: ForStatement):
        """Generate code for a for statement"""
        # Generate initialization
        if node.init:
            self.generate_statement(node.init)
        
        # Generate while loop
        if node.condition:
            condition_code = self.generate_expression(node.condition)
        else:
            condition_code = "True"
        
        self.emit(f"while {condition_code}:")
        self.increase_indent()
        
        # Generate body
        self.generate_statement(node.body)
        
        # Generate update
        if node.update:
            update_code = self.generate_expression(node.update)
            self.emit(f"{update_code}")
        
        self.decrease_indent()
    
    def generate_return_statement(self, node: ReturnStatement):
        """Generate code for a return statement"""
        if self.in_main_function:
            if node.expression:
                expr_code = self.generate_expression(node.expression)
                self.emit(f"cpp_runtime.set_return({expr_code})")
                self.emit(f"sys.exit({expr_code})")
            else:
                self.emit("cpp_runtime.set_return(0)")
                self.emit("sys.exit(0)")
        else:
            if node.expression:
                expr_code = self.generate_expression(node.expression)
                self.emit(f"return {expr_code}")
            else:
                self.emit("return None")
    
    def generate_expression(self, node: Expression) -> str:
        """Generate code for an expression and return the code string"""
        if isinstance(node, Literal):
            return self.generate_literal(node)
        elif isinstance(node, Identifier):
            return self.generate_identifier(node)
        elif isinstance(node, BinaryOperation):
            return self.generate_binary_operation(node)
        elif isinstance(node, UnaryOperation):
            return self.generate_unary_operation(node)
        elif isinstance(node, Assignment):
            return self.generate_assignment(node)
        elif isinstance(node, FunctionCall):
            return self.generate_function_call(node)
        else:
            return f"# Unsupported expression: {type(node)}"
    
    def generate_literal(self, node: Literal) -> str:
        """Generate code for a literal"""
        if node.type_name == 'string':
            return repr(node.value)
        elif node.type_name == 'char':
            return repr(node.value)
        elif node.type_name == 'bool':
            return str(node.value)
        else:
            return str(node.value)
    
    def generate_identifier(self, node: Identifier) -> str:
        """Generate code for an identifier"""
        return node.name
    
    def generate_binary_operation(self, node: BinaryOperation) -> str:
        """Generate code for a binary operation"""
        left_code = self.generate_expression(node.left)
        right_code = self.generate_expression(node.right)
        
        # Handle special case for cout <<
        if node.operator == '<<':
            return f"{left_code} << {right_code}"
        
        # Map C++ operators to Python operators
        operator_map = {
            '+': '+',
            '-': '-',
            '*': '*',
            '/': '//',  # Integer division for int types
            '%': '%',
            '==': '==',
            '!=': '!=',
            '<': '<',
            '>': '>',
            '<=': '<=',
            '>=': '>=',
            '&&': ' and ',
            '||': ' or ',
        }
        
        python_op = operator_map.get(node.operator, node.operator)
        
        # Handle special cases
        if node.operator == '/':
            # Check if we need float division
            return f"({left_code} / {right_code})"
        
        return f"({left_code} {python_op} {right_code})"
    
    def generate_unary_operation(self, node: UnaryOperation) -> str:
        """Generate code for a unary operation"""
        operand_code = self.generate_expression(node.operand)
        
        if node.operator == '!':
            return f"(not {operand_code})"
        elif node.operator == '-':
            return f"(-{operand_code})"
        elif node.operator == '+':
            return f"(+{operand_code})"
        elif node.operator == '++':
            # Pre-increment
            self.emit(f"{operand_code} += 1")
            return operand_code
        elif node.operator == '--':
            # Pre-decrement
            self.emit(f"{operand_code} -= 1")
            return operand_code
        elif node.operator == '++_post':
            # Post-increment
            temp_var = self.get_temp_var()
            self.emit(f"{temp_var} = {operand_code}")
            self.emit(f"{operand_code} += 1")
            return temp_var
        elif node.operator == '--_post':
            # Post-decrement
            temp_var = self.get_temp_var()
            self.emit(f"{temp_var} = {operand_code}")
            self.emit(f"{operand_code} -= 1")
            return temp_var
        
        return f"({node.operator}{operand_code})"
    
    def generate_assignment(self, node: Assignment) -> str:
        """Generate code for an assignment"""
        target_code = self.generate_expression(node.target)
        value_code = self.generate_expression(node.value)
        
        assignment = f"{target_code} = {value_code}"
        self.emit(assignment)
        return target_code
    
    def generate_function_call(self, node: FunctionCall) -> str:
        """Generate code for a function call"""
        # Handle special built-in functions
        if node.name == 'cout':
            # Handle cout << operations
            if len(node.arguments) == 1:
                arg_code = self.generate_expression(node.arguments[0])
                return f"cout << {arg_code}"
            else:
                return "cout"
        
        # Regular function call
        arg_codes = []
        for arg in node.arguments:
            arg_codes.append(self.generate_expression(arg))
        
        args_str = ", ".join(arg_codes)
        return f"{node.name}({args_str})"
    
    def execute(self) -> tuple[str, int]:
        """Execute the generated code and return output and exit code"""
        try:
            # Create a new namespace for execution
            execution_globals = {
                '__name__': '__main__',
                '__runtime': CppRuntime(),
                'sys': sys,
                'math': __import__('math'),
            }
            
            # Execute the generated code
            exec(self.generated_code, execution_globals)
            
            # Return output and exit code
            runtime = execution_globals['__runtime']
            return runtime.get_output(), runtime.return_value
            
        except SystemExit as e:
            # Capture the runtime from the exception context
            return "", e.code if e.code is not None else 0
        except Exception as e:
            return f"Runtime Error: {e}", 1

class CppRuntime:
    """Runtime support class for C++ simulation"""
    def __init__(self):
        self.output_buffer = []
        self.return_value = 0
        self.return_called = False
    
    def cout_output(self, value):
        """Handle cout << value"""
        if isinstance(value, str) and value.startswith('"') and value.endswith('"'):
            value = value[1:-1]  # Remove quotes
        self.output_buffer.append(str(value))
        return self
    
    def cout_endl(self):
        """Handle cout << endl"""
        self.output_buffer.append('\n')
        return self
    
    def get_output(self):
        """Get the accumulated output"""
        return ''.join(self.output_buffer)
    
    def set_return(self, value):
        """Set the return value"""
        self.return_value = value
        self.return_called = True
    
    def __lshift__(self, other):
        """Overload << operator for cout"""
        if other == '\n' or str(other) == 'endl':
            return self.cout_endl()
        else:
            return self.cout_output(other)

def main():
    """Test the code generator"""
    from lexer import Lexer
    
    sample_code = """
#include <iostream>
using namespace std;

int main() {
    int x = 10;
    int y = 20;
    int sum = x + y;
    cout << "Sum: " << sum << endl;
    
    if (sum > 25) {
        cout << "Sum is greater than 25" << endl;
        return 1;
    } else {
        cout << "Sum is not greater than 25" << endl;
        return 0;
    }
}
"""
    
    # Compile
    lexer = Lexer(sample_code)
    tokens = lexer.tokenize()
    
    parser = Parser(tokens)
    ast = parser.parse()
    
    analyzer = SemanticAnalyzer()
    if not analyzer.analyze(ast):
        print("Semantic errors found:")
        for error in analyzer.errors:
            print(f"  {error}")
        return
    
    # Generate code
    generator = CodeGenerator(analyzer)
    generated_code = generator.generate(ast)
    
    print("Generated Python Code:")
    print("=" * 50)
    print(generated_code)
    print("=" * 50)
    
    # Execute
    print("\nExecution Output:")
    try:
        exec(generated_code)
    except SystemExit as e:
        print(f"\nProgram exited with code: {e.code}")

if __name__ == "__main__":
    main()