"""
C++ Semantic Analyzer
This module performs semantic analysis including type checking, symbol table management,
and scope resolution.
"""

from typing import Dict, List, Optional, Any, Union
from parser import *

class Symbol:
    """Represents a symbol in the symbol table"""
    def __init__(self, name: str, symbol_type: str, data_type: str, value: Any = None):
        self.name = name
        self.symbol_type = symbol_type  # 'variable', 'function', 'parameter'
        self.data_type = data_type      # 'int', 'float', 'void', etc.
        self.value = value
        self.is_initialized = value is not None
    
    def __repr__(self):
        return f"Symbol({self.name}, {self.symbol_type}, {self.data_type}, {self.value})"

class Scope:
    """Represents a lexical scope"""
    def __init__(self, name: str, parent: Optional['Scope'] = None):
        self.name = name
        self.parent = parent
        self.symbols: Dict[str, Symbol] = {}
        self.children: List['Scope'] = []
    
    def define_symbol(self, symbol: Symbol) -> None:
        """Define a symbol in this scope"""
        if symbol.name in self.symbols:
            raise SemanticError(f"Symbol '{symbol.name}' already defined in scope '{self.name}'")
        self.symbols[symbol.name] = symbol
    
    def lookup_symbol(self, name: str) -> Optional[Symbol]:
        """Look up a symbol in this scope or parent scopes"""
        if name in self.symbols:
            return self.symbols[name]
        elif self.parent:
            return self.parent.lookup_symbol(name)
        return None
    
    def __repr__(self):
        return f"Scope({self.name}, symbols={list(self.symbols.keys())})"

class SemanticError(Exception):
    """Exception raised for semantic errors"""
    pass

class SemanticAnalyzer:
    """Performs semantic analysis on the AST"""
    
    def __init__(self):
        self.global_scope = Scope("global")
        self.current_scope = self.global_scope
        self.scope_stack = [self.global_scope]
        self.current_function = None
        self.errors = []
        
        # Built-in types
        self.built_in_types = {
            'int', 'float', 'double', 'char', 'bool', 'void', 'string'
        }
        # Track user-defined class/struct types
        self.user_types = set()
        
        # Type compatibility rules
        self.type_compatibility = {
            ('int', 'int'): 'int',
            ('int', 'float'): 'float',
            ('int', 'double'): 'double',
            ('float', 'int'): 'float',
            ('float', 'float'): 'float',
            ('float', 'double'): 'double',
            ('double', 'int'): 'double',
            ('double', 'float'): 'double',
            ('double', 'double'): 'double',
            ('bool', 'bool'): 'bool',
            ('char', 'char'): 'char',
            ('string', 'string'): 'string',
        }
        
        # Initialize built-in functions
        self.init_built_ins()
    
    def init_built_ins(self):
        """Initialize built-in functions and symbols"""
        # cout symbol (simplified)
        cout_symbol = Symbol('cout', 'variable', 'ostream')
        cout_symbol.is_initialized = True  # cout is always available
        self.global_scope.define_symbol(cout_symbol)
        
        # std::cout symbol
        std_cout_symbol = Symbol('std::cout', 'variable', 'ostream')
        std_cout_symbol.is_initialized = True
        self.global_scope.define_symbol(std_cout_symbol)
        
        # endl symbol
        endl_symbol = Symbol('endl', 'variable', 'string', '\n')
        endl_symbol.is_initialized = True  # endl is always available
        self.global_scope.define_symbol(endl_symbol)
        
        # std::endl symbol
        std_endl_symbol = Symbol('std::endl', 'variable', 'string', '\n')
        std_endl_symbol.is_initialized = True
        self.global_scope.define_symbol(std_endl_symbol)
    
    def error(self, message: str):
        """Add an error to the error list"""
        self.errors.append(f"Semantic Error: {message}")
    
    def enter_scope(self, name: str) -> Scope:
        """Enter a new scope"""
        new_scope = Scope(name, self.current_scope)
        self.current_scope.children.append(new_scope)
        self.current_scope = new_scope
        self.scope_stack.append(new_scope)
        return new_scope
    
    def exit_scope(self):
        """Exit the current scope"""
        if len(self.scope_stack) > 1:
            self.scope_stack.pop()
            self.current_scope = self.scope_stack[-1]
    
    def get_type_compatibility(self, type1: str, type2: str) -> Optional[str]:
        """Get the compatible type for two types"""
        return self.type_compatibility.get((type1, type2)) or \
               self.type_compatibility.get((type2, type1))
    
    def analyze(self, ast: Program) -> bool:
        """Analyze the entire AST and return True if no errors"""
        self.visit_program(ast)
        return len(self.errors) == 0
    
    def visit_program(self, node: Program):
        """Visit a program node"""
        for declaration in node.declarations:
            self.visit_declaration(declaration)
    
    def visit_declaration(self, node: Statement):
        """Visit a declaration"""
        if isinstance(node, IncludeDirective):
            self.visit_include_directive(node)
        elif isinstance(node, UsingNamespace):
            self.visit_using_namespace(node)
        elif isinstance(node, FunctionDeclaration):
            self.visit_function_declaration(node)
        elif isinstance(node, VariableDeclaration):
            self.visit_variable_declaration(node)
        elif isinstance(node, ClassDeclaration):
            self.visit_class_declaration(node)
        else:
            self.error(f"Unknown declaration type: {type(node)}")

    def visit_class_declaration(self, node: ClassDeclaration):
        """Register class/struct type and its members (simplified)"""
        if node.name in self.built_in_types or node.name in self.user_types:
            self.error(f"Type '{node.name}' already defined")
            return
        self.user_types.add(node.name)
        # Create a scope for class members (not used in further analysis yet)
        class_scope = Scope(f"class_{node.name}", self.current_scope)
        for member in node.members:
            if isinstance(member, VariableDeclaration):
                # Register member symbol inside class scope
                class_scope.define_symbol(Symbol(member.name, 'member', member.var_type.name))
        self.current_scope.children.append(class_scope)
    
    def visit_include_directive(self, node: IncludeDirective):
        """Visit an include directive"""
        # For now, just validate that it's a known header
        known_headers = ['<iostream>', '"iostream"']
        if node.header not in known_headers:
            pass  # Just warn, don't error
    
    def visit_using_namespace(self, node: UsingNamespace):
        """Visit a using namespace directive"""
        # For now, just validate that it's std
        if node.namespace != 'std':
            self.error(f"Unknown namespace: {node.namespace}")
    
    def visit_function_declaration(self, node: FunctionDeclaration):
        """Visit a function declaration"""
        # Check return type
        if node.return_type.name not in self.built_in_types:
            self.error(f"Unknown return type: {node.return_type.name}")
        
        # Check if function already exists
        existing_symbol = self.current_scope.symbols.get(node.name)
        if existing_symbol:
            self.error(f"Function '{node.name}' already defined")
            return
        
        # Create function symbol
        param_types = [param_type.name for param_type, _ in node.parameters]
        func_symbol = Symbol(node.name, 'function', node.return_type.name)
        func_symbol.parameters = node.parameters
        self.current_scope.define_symbol(func_symbol)
        
        # Enter function scope
        self.current_function = node
        func_scope = self.enter_scope(f"function_{node.name}")
        
        # Add parameters to function scope
        for param_type, param_name in node.parameters:
            if param_type.name not in self.built_in_types:
                self.error(f"Unknown parameter type: {param_type.name}")
            
            param_symbol = Symbol(param_name, 'parameter', param_type.name)
            param_symbol.is_initialized = True  # Parameters are always initialized
            func_scope.define_symbol(param_symbol)
        
        # Analyze function body
        self.visit_statement(node.body)
        
        # Check return statements
        self.check_return_statements(node.body, node.return_type.name)
        
        # Exit function scope
        self.exit_scope()
        self.current_function = None
    
    def check_return_statements(self, body: Statement, expected_type: str):
        """Check that all return statements match the expected type"""
        def check_returns(stmt: Statement):
            if isinstance(stmt, ReturnStatement):
                if stmt.expression is None:
                    if expected_type != 'void':
                        self.error(f"Function should return {expected_type}, but return statement has no value")
                else:
                    expr_type = self.visit_expression(stmt.expression)
                    if expr_type != expected_type:
                        if not self.get_type_compatibility(expr_type, expected_type):
                            self.error(f"Return type mismatch: expected {expected_type}, got {expr_type}")
            elif isinstance(stmt, Block):
                for s in stmt.statements:
                    check_returns(s)
            elif isinstance(stmt, IfStatement):
                check_returns(stmt.then_stmt)
                if stmt.else_stmt:
                    check_returns(stmt.else_stmt)
            elif isinstance(stmt, WhileStatement):
                check_returns(stmt.body)
            elif isinstance(stmt, ForStatement):
                check_returns(stmt.body)
        
        check_returns(body)
    
    def visit_statement(self, node: Statement):
        """Visit a statement"""
        if isinstance(node, VariableDeclaration):
            self.visit_variable_declaration(node)
        elif isinstance(node, ExpressionStatement):
            self.visit_expression_statement(node)
        elif isinstance(node, Block):
            self.visit_block(node)
        elif isinstance(node, IfStatement):
            self.visit_if_statement(node)
        elif isinstance(node, WhileStatement):
            self.visit_while_statement(node)
        elif isinstance(node, ForStatement):
            self.visit_for_statement(node)
        elif isinstance(node, ReturnStatement):
            self.visit_return_statement(node)
        else:
            self.error(f"Unknown statement type: {type(node)}")
    
    def visit_variable_declaration(self, node: VariableDeclaration):
        """Visit a variable declaration"""
        # Check type
        if node.var_type.name not in self.built_in_types:
            # Allow user-defined types and simple pointer/reference forms
            base_name = node.var_type.name
            if base_name not in self.user_types:
                self.error(f"Unknown type: {node.var_type.name}")
        
        # Check if variable already exists in current scope
        if node.name in self.current_scope.symbols:
            self.error(f"Variable '{node.name}' already defined in current scope")
            return
        
        # Check initializer type
        initializer_type = None
        if node.initializer:
            initializer_type = self.visit_expression(node.initializer)
            # Type compatibility check
            if initializer_type != node.var_type.name:
                compatible_type = self.get_type_compatibility(node.var_type.name, initializer_type)
                if not compatible_type:
                    self.error(f"Cannot assign {initializer_type} to {node.var_type.name}")
        
        # Create symbol
        symbol = Symbol(node.name, 'variable', node.var_type.name)
        symbol.is_initialized = node.initializer is not None
        self.current_scope.define_symbol(symbol)
    
    def visit_expression_statement(self, node: ExpressionStatement):
        """Visit an expression statement"""
        self.visit_expression(node.expression)
    
    def visit_block(self, node: Block):
        """Visit a block statement"""
        # Don't create extra scope if we're already in a function scope
        # (the function already created its own scope)
        need_new_scope = self.current_scope.name.startswith("function_") == False
        
        if need_new_scope:
            block_scope = self.enter_scope("block")
        
        for statement in node.statements:
            self.visit_statement(statement)
        
        if need_new_scope:
            self.exit_scope()
    
    def visit_if_statement(self, node: IfStatement):
        """Visit an if statement"""
        # Check condition
        condition_type = self.visit_expression(node.condition)
        if condition_type not in ['bool', 'int']:  # Allow int for C-style boolean
            self.error(f"If condition must be boolean or integer, got {condition_type}")
        
        # Visit branches
        self.visit_statement(node.then_stmt)
        if node.else_stmt:
            self.visit_statement(node.else_stmt)
    
    def visit_while_statement(self, node: WhileStatement):
        """Visit a while statement"""
        # Check condition
        condition_type = self.visit_expression(node.condition)
        if condition_type not in ['bool', 'int']:
            self.error(f"While condition must be boolean or integer, got {condition_type}")
        
        # Visit body
        self.visit_statement(node.body)
    
    def visit_for_statement(self, node: ForStatement):
        """Visit a for statement"""
        # Enter new scope for for loop
        for_scope = self.enter_scope("for_loop")
        
        # Visit initialization
        if node.init:
            self.visit_statement(node.init)
        
        # Check condition
        if node.condition:
            condition_type = self.visit_expression(node.condition)
            if condition_type not in ['bool', 'int']:
                self.error(f"For condition must be boolean or integer, got {condition_type}")
        
        # Visit update
        if node.update:
            self.visit_expression(node.update)
        
        # Visit body
        self.visit_statement(node.body)
        
        # Exit for scope
        self.exit_scope()
    
    def visit_return_statement(self, node: ReturnStatement):
        """Visit a return statement"""
        if not self.current_function:
            self.error("Return statement outside of function")
            return
        
        expected_type = self.current_function.return_type.name
        
        if node.expression:
            expr_type = self.visit_expression(node.expression)
            if expr_type != expected_type:
                compatible_type = self.get_type_compatibility(expected_type, expr_type)
                if not compatible_type:
                    self.error(f"Return type mismatch: expected {expected_type}, got {expr_type}")
        else:
            if expected_type != 'void':
                self.error(f"Function should return {expected_type}, but return statement has no value")
    
    def visit_expression(self, node: Expression) -> str:
        """Visit an expression and return its type"""
        if isinstance(node, Literal):
            return self.visit_literal(node)
        elif isinstance(node, Identifier):
            return self.visit_identifier(node)
        elif isinstance(node, BinaryOperation):
            return self.visit_binary_operation(node)
        elif isinstance(node, UnaryOperation):
            return self.visit_unary_operation(node)
        elif isinstance(node, Assignment):
            return self.visit_assignment(node)
        elif isinstance(node, FunctionCall):
            return self.visit_function_call(node)
        else:
            self.error(f"Unknown expression type: {type(node)}")
            return 'unknown'
    
    def visit_literal(self, node: Literal) -> str:
        """Visit a literal and return its type"""
        return node.type_name
    
    def visit_identifier(self, node: Identifier) -> str:
        """Visit an identifier and return its type"""
        symbol = self.current_scope.lookup_symbol(node.name)
        if not symbol:
            self.error(f"Undefined identifier: {node.name}")
            return 'unknown'
        
        if symbol.symbol_type == 'variable' and not symbol.is_initialized:
            self.error(f"Variable '{node.name}' used before initialization")
        
        return symbol.data_type
    
    def visit_binary_operation(self, node: BinaryOperation) -> str:
        """Visit a binary operation and return its type"""
        left_type = self.visit_expression(node.left)
        right_type = self.visit_expression(node.right)
        
        # Comparison operators
        if node.operator in ['==', '!=', '<', '>', '<=', '>=']:
            compatible_type = self.get_type_compatibility(left_type, right_type)
            if not compatible_type:
                self.error(f"Cannot compare {left_type} and {right_type}")
            return 'bool'
        
        # Logical operators
        elif node.operator in ['&&', '||']:
            if left_type not in ['bool', 'int'] or right_type not in ['bool', 'int']:
                self.error(f"Logical operators require boolean operands")
            return 'bool'
        
        # Stream operator (cout <<)
        elif node.operator == '<<':
            if left_type == 'ostream':
                return 'ostream'  # Allow chaining
            else:
                self.error(f"Left shift operator requires ostream on left side, got {left_type}")
                return 'unknown'
        
        # Arithmetic operators
        elif node.operator in ['+', '-', '*', '/', '%']:
            compatible_type = self.get_type_compatibility(left_type, right_type)
            if not compatible_type:
                self.error(f"Cannot perform {node.operator} on {left_type} and {right_type}")
                return 'unknown'
            
            # Special case for string concatenation
            if left_type == 'string' or right_type == 'string':
                if node.operator == '+':
                    return 'string'
                else:
                    self.error(f"Cannot perform {node.operator} on strings")
                    return 'unknown'
            
            return compatible_type
        
        else:
            self.error(f"Unknown binary operator: {node.operator}")
            return 'unknown'
    
    def visit_unary_operation(self, node: UnaryOperation) -> str:
        """Visit a unary operation and return its type"""
        operand_type = self.visit_expression(node.operand)
        
        if node.operator == '!':
            if operand_type not in ['bool', 'int']:
                self.error(f"Logical NOT requires boolean operand, got {operand_type}")
            return 'bool'
        elif node.operator in ['+', '-']:
            if operand_type not in ['int', 'float', 'double']:
                self.error(f"Unary {node.operator} requires numeric operand, got {operand_type}")
            return operand_type
        elif node.operator in ['++', '--', '++_post', '--_post']:
            if operand_type not in ['int', 'float', 'double']:
                self.error(f"Increment/decrement requires numeric operand, got {operand_type}")
            # Check if operand is assignable
            if not isinstance(node.operand, Identifier):
                self.error("Increment/decrement requires assignable operand")
            return operand_type
        else:
            self.error(f"Unknown unary operator: {node.operator}")
            return 'unknown'
    
    def visit_assignment(self, node: Assignment) -> str:
        """Visit an assignment and return its type"""
        # Check if target exists and is assignable
        symbol = self.current_scope.lookup_symbol(node.target.name)
        if not symbol:
            self.error(f"Undefined variable: {node.target.name}")
            return 'unknown'
        
        if symbol.symbol_type != 'variable':
            self.error(f"Cannot assign to {symbol.symbol_type}")
            return 'unknown'
        
        # Check value type
        value_type = self.visit_expression(node.value)
        
        # Type compatibility check
        if value_type != symbol.data_type:
            compatible_type = self.get_type_compatibility(symbol.data_type, value_type)
            if not compatible_type:
                self.error(f"Cannot assign {value_type} to {symbol.data_type}")
                return symbol.data_type
        
        # Mark as initialized
        symbol.is_initialized = True
        return symbol.data_type
    
    def visit_function_call(self, node: FunctionCall) -> str:
        """Visit a function call and return its type"""
        # Special handling for built-in functions
        if node.name == 'cout':
            # Handle cout << expressions (simplified)
            return 'ostream'
        
        # Look up function symbol
        symbol = self.current_scope.lookup_symbol(node.name)
        if not symbol:
            self.error(f"Undefined function: {node.name}")
            return 'unknown'
        
        if symbol.symbol_type != 'function':
            self.error(f"'{node.name}' is not a function")
            return 'unknown'
        
        # Check argument count and types
        expected_params = getattr(symbol, 'parameters', [])
        if len(node.arguments) != len(expected_params):
            self.error(f"Function '{node.name}' expects {len(expected_params)} arguments, got {len(node.arguments)}")
            return symbol.data_type
        
        for i, (arg, (param_type, _)) in enumerate(zip(node.arguments, expected_params)):
            arg_type = self.visit_expression(arg)
            if arg_type != param_type.name:
                compatible_type = self.get_type_compatibility(param_type.name, arg_type)
                if not compatible_type:
                    self.error(f"Argument {i+1} type mismatch: expected {param_type.name}, got {arg_type}")
        
        return symbol.data_type

def main():
    """Test the semantic analyzer"""
    from lexer import Lexer
    
    sample_code = """
#include <iostream>
using namespace std;

int main() {
    int x = 10;
    int y = 20;
    int sum = x + y;
    
    if (sum > 25) {
        return 1;
    } else {
        return 0;
    }
}
"""
    
    lexer = Lexer(sample_code)
    tokens = lexer.tokenize()
    
    parser = Parser(tokens)
    ast = parser.parse()
    
    analyzer = SemanticAnalyzer()
    success = analyzer.analyze(ast)
    
    print("Semantic Analysis Results:")
    print(f"Success: {success}")
    if analyzer.errors:
        print("Errors:")
        for error in analyzer.errors:
            print(f"  {error}")
    else:
        print("No semantic errors found!")
    
    print("\nSymbol Table:")
    def print_scope(scope, indent=0):
        print("  " * indent + f"Scope: {scope.name}")
        for name, symbol in scope.symbols.items():
            print("  " * (indent + 1) + f"{name}: {symbol}")
        for child in scope.children:
            print_scope(child, indent + 1)
    
    print_scope(analyzer.global_scope)

if __name__ == "__main__":
    main()