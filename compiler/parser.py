"""
C++ Parser with Abstract Syntax Tree (AST)
This module parses tokens into an Abstract Syntax Tree using recursive descent parsing.
"""

from abc import ABC, abstractmethod
from typing import List, Optional, Union, Any
from lexer import Token, TokenType, Lexer

# AST Node Classes
class ASTNode(ABC):
    """Base class for all AST nodes"""
    pass

class Expression(ASTNode):
    """Base class for expressions"""
    pass

class Statement(ASTNode):
    """Base class for statements"""
    pass

class Type(ASTNode):
    """Represents a type"""
    def __init__(self, name: str, is_pointer: bool = False, is_reference: bool = False, is_const: bool = False):
        self.name = name
        self.is_pointer = is_pointer
        self.is_reference = is_reference
        self.is_const = is_const
    
    def __repr__(self):
        qual = ''
        if self.is_const:
            qual += 'const '
        qual += self.name
        if self.is_pointer:
            qual += '*'
        if self.is_reference:
            qual += '&'
        return f"Type({qual})"

# Expression nodes
class Literal(Expression):
    """Represents a literal value"""
    def __init__(self, value: Any, type_name: str):
        self.value = value
        self.type_name = type_name
    
    def __repr__(self):
        return f"Literal({self.value}, {self.type_name})"

class Identifier(Expression):
    """Represents an identifier"""
    def __init__(self, name: str):
        self.name = name
    
    def __repr__(self):
        return f"Identifier({self.name})"

class BinaryOperation(Expression):
    """Represents a binary operation"""
    def __init__(self, left: Expression, operator: str, right: Expression):
        self.left = left
        self.operator = operator
        self.right = right
    
    def __repr__(self):
        return f"BinaryOp({self.left} {self.operator} {self.right})"

class UnaryOperation(Expression):
    """Represents a unary operation"""
    def __init__(self, operator: str, operand: Expression):
        self.operator = operator
        self.operand = operand
    
    def __repr__(self):
        return f"UnaryOp({self.operator}{self.operand})"

class FunctionCall(Expression):
    """Represents a function call"""
    def __init__(self, name: str, arguments: List[Expression]):
        self.name = name
        self.arguments = arguments
    
    def __repr__(self):
        args = ', '.join(str(arg) for arg in self.arguments)
        return f"FunctionCall({self.name}({args}))"

class Assignment(Expression):
    """Represents an assignment"""
    def __init__(self, target: Identifier, value: Expression):
        self.target = target
        self.value = value
    
    def __repr__(self):
        return f"Assignment({self.target} = {self.value})"

# Statement nodes
class ExpressionStatement(Statement):
    """Represents an expression used as a statement"""
    def __init__(self, expression: Expression):
        self.expression = expression
    
    def __repr__(self):
        return f"ExprStmt({self.expression})"

class VariableDeclaration(Statement):
    """Represents a variable declaration"""
    def __init__(self, var_type: Type, name: str, initializer: Optional[Expression] = None):
        self.var_type = var_type
        self.name = name
        self.initializer = initializer
    
    def __repr__(self):
        init_str = f" = {self.initializer}" if self.initializer else ""
        return f"VarDecl({self.var_type} {self.name}{init_str})"

class Block(Statement):
    """Represents a block of statements"""
    def __init__(self, statements: List[Statement]):
        self.statements = statements
    
    def __repr__(self):
        return f"Block([{', '.join(str(stmt) for stmt in self.statements)}])"

class IfStatement(Statement):
    """Represents an if statement"""
    def __init__(self, condition: Expression, then_stmt: Statement, else_stmt: Optional[Statement] = None):
        self.condition = condition
        self.then_stmt = then_stmt
        self.else_stmt = else_stmt
    
    def __repr__(self):
        else_str = f" else {self.else_stmt}" if self.else_stmt else ""
        return f"If({self.condition}) {self.then_stmt}{else_str}"

class WhileStatement(Statement):
    """Represents a while loop"""
    def __init__(self, condition: Expression, body: Statement):
        self.condition = condition
        self.body = body
    
    def __repr__(self):
        return f"While({self.condition}) {self.body}"

class ForStatement(Statement):
    """Represents a for loop"""
    def __init__(self, init: Optional[Statement], condition: Optional[Expression], 
                 update: Optional[Expression], body: Statement):
        self.init = init
        self.condition = condition
        self.update = update
        self.body = body
    
    def __repr__(self):
        return f"For({self.init}; {self.condition}; {self.update}) {self.body}"

class ReturnStatement(Statement):
    """Represents a return statement"""
    def __init__(self, expression: Optional[Expression] = None):
        self.expression = expression
    
    def __repr__(self):
        expr_str = f" {self.expression}" if self.expression else ""
        return f"Return{expr_str}"

class FunctionDeclaration(Statement):
    """Represents a function declaration"""
    def __init__(self, return_type: Type, name: str, parameters: List[tuple], body: Block):
        self.return_type = return_type
        self.name = name
        self.parameters = parameters  # List of (Type, name) tuples
        self.body = body
    
    def __repr__(self):
        params = ', '.join(f"{param_type} {param_name}" for param_type, param_name in self.parameters)
        return f"FuncDecl({self.return_type} {self.name}({params}) {self.body})"

class Program(ASTNode):
    """Represents the entire program"""
    def __init__(self, declarations: List[Statement]):
        self.declarations = declarations
    
    def __repr__(self):
        return f"Program([{', '.join(str(decl) for decl in self.declarations)}])"

class IncludeDirective(Statement):
    """Represents an #include directive"""
    def __init__(self, header: str):
        self.header = header
    
    def __repr__(self):
        return f"Include({self.header})"

class UsingNamespace(Statement):
    """Represents a using namespace directive"""
    def __init__(self, namespace: str):
        self.namespace = namespace
    
    def __repr__(self):
        return f"UsingNamespace({self.namespace})"

class ClassDeclaration(Statement):
    """Represents a class/struct declaration (simplified)"""
    def __init__(self, name: str, members: List[Statement], is_struct: bool = False):
        self.name = name
        self.members = members  # Only variable declarations for now
        self.is_struct = is_struct
    def __repr__(self):
        kind = 'Struct' if self.is_struct else 'Class'
        return f"{kind}Decl({self.name}, members=[{', '.join(str(m) for m in self.members)}])"

# Parser class
class Parser:
    """Recursive descent parser for C++"""
    
    def __init__(self, tokens: List[Token]):
        self.tokens = tokens
        self.current = 0
    
    def current_token(self) -> Token:
        """Get the current token"""
        if self.current >= len(self.tokens):
            return self.tokens[-1]  # EOF token
        return self.tokens[self.current]
    
    def peek_token(self, offset: int = 1) -> Token:
        """Peek at a token ahead"""
        pos = self.current + offset
        if pos >= len(self.tokens):
            return self.tokens[-1]  # EOF token
        return self.tokens[pos]
    
    def advance(self) -> Token:
        """Move to the next token and return the previous one"""
        token = self.current_token()
        if self.current < len(self.tokens) - 1:
            self.current += 1
        return token
    
    def match(self, *token_types: TokenType) -> bool:
        """Check if current token matches any of the given types"""
        return self.current_token().type in token_types
    
    def consume(self, token_type: TokenType, message: str = "") -> Token:
        """Consume a token of the expected type or raise an error"""
        if self.current_token().type == token_type:
            return self.advance()
        
        error_msg = f"Expected {token_type.name}"
        if message:
            error_msg += f": {message}"
        error_msg += f", got {self.current_token().type.name}"
        raise SyntaxError(error_msg)
    
    def skip_newlines(self):
        """Skip newline tokens"""
        while self.match(TokenType.NEWLINE):
            self.advance()
    
    def parse(self) -> Program:
        """Parse the entire program"""
        declarations = []
        
        while not self.match(TokenType.EOF):
            self.skip_newlines()
            if self.match(TokenType.EOF):
                break
                
            decl = self.parse_declaration()
            if decl:
                declarations.append(decl)
        
        return Program(declarations)
    
    def parse_declaration(self) -> Optional[Statement]:
        """Parse a top-level declaration"""
        self.skip_newlines()
        
        if self.match(TokenType.HASH):
            return self.parse_preprocessor()
        elif self.match(TokenType.USING):
            return self.parse_using_namespace()
        elif self.match(TokenType.CLASS, TokenType.STRUCT):
            return self.parse_class_declaration()
        elif self.match(TokenType.INT, TokenType.FLOAT, TokenType.DOUBLE, TokenType.CHAR, TokenType.BOOL, TokenType.VOID):
            return self.parse_function_or_variable()
        
        return None

    def parse_class_declaration(self) -> ClassDeclaration:
        is_struct = self.match(TokenType.STRUCT)
        self.advance()  # consume class/struct
        name = self.consume(TokenType.IDENTIFIER, "Expected identifier after class/struct").value
        # Optional inheritance list (ignored)
        if self.match(TokenType.COLON):
            while not self.match(TokenType.LEFT_BRACE, TokenType.EOF):
                self.advance()
        self.consume(TokenType.LEFT_BRACE)
        members: List[Statement] = []
        while not self.match(TokenType.RIGHT_BRACE, TokenType.EOF):
            self.skip_newlines()
            if self.match(TokenType.RIGHT_BRACE):
                break
            if self.match(TokenType.INT, TokenType.FLOAT, TokenType.DOUBLE, TokenType.CHAR, TokenType.BOOL):
                mtype = self.parse_type()
                mname = self.consume(TokenType.IDENTIFIER).value
                self.consume(TokenType.SEMICOLON)
                members.append(VariableDeclaration(mtype, mname))
            else:
                # Skip unsupported member syntax for now
                self.advance()
        self.consume(TokenType.RIGHT_BRACE)
        # Optional trailing semicolon
        if self.match(TokenType.SEMICOLON):
            self.advance()
        return ClassDeclaration(name, members, is_struct)
    
    def parse_preprocessor(self) -> Statement:
        """Parse preprocessor directives"""
        self.consume(TokenType.HASH)
        
        if self.match(TokenType.INCLUDE):
            self.advance()  # consume 'include'
            
            # Handle <iostream> or "header.h"
            header = ""
            if self.match(TokenType.LESS_THAN):
                self.advance()
                header += "<"
                # Read everything until >
                while not self.match(TokenType.GREATER_THAN) and not self.match(TokenType.EOF, TokenType.NEWLINE):
                    header += self.advance().value
                if self.match(TokenType.GREATER_THAN):
                    self.consume(TokenType.GREATER_THAN)
                    header += ">"
            elif self.match(TokenType.STRING_LITERAL):
                header = self.advance().value
            
            return IncludeDirective(header)
        
        # Skip unknown preprocessor directives
        while not self.match(TokenType.NEWLINE, TokenType.EOF):
            self.advance()
        return None
    
    def parse_using_namespace(self) -> Statement:
        """Parse using namespace directive"""
        self.consume(TokenType.USING)
        self.consume(TokenType.NAMESPACE)
        
        namespace = self.consume(TokenType.STD).value
        self.consume(TokenType.SEMICOLON)
        
        return UsingNamespace(namespace)
    
    def parse_type(self) -> Type:
        """Parse a type"""
        is_const = False
        if self.match(TokenType.CONST):
            is_const = True
            self.advance()
        if self.match(TokenType.INT, TokenType.FLOAT, TokenType.DOUBLE, TokenType.CHAR, TokenType.BOOL, TokenType.VOID):
            base = self.advance().value
            is_pointer = False
            is_reference = False
            # Collect * and & (single level for now)
            if self.match(TokenType.MULTIPLY):
                self.advance()
                is_pointer = True
            if self.match(TokenType.AMPERSAND):
                self.advance()
                is_reference = True
            return Type(base, is_pointer=is_pointer, is_reference=is_reference, is_const=is_const)
        raise SyntaxError(f"Expected type, got {self.current_token().type.name}")
    
    def parse_function_or_variable(self) -> Statement:
        """Parse function or variable declaration"""
        var_type = self.parse_type()
        name = self.consume(TokenType.IDENTIFIER).value
        
        if self.match(TokenType.LEFT_PAREN):
            # Function declaration
            return self.parse_function_declaration(var_type, name)
        else:
            # Variable declaration
            return self.parse_variable_declaration(var_type, name)
    
    def parse_function_declaration(self, return_type: Type, name: str) -> FunctionDeclaration:
        """Parse function declaration"""
        self.consume(TokenType.LEFT_PAREN)
        
        parameters = []
        if not self.match(TokenType.RIGHT_PAREN):
            # Parse parameter list
            param_type = self.parse_type()
            param_name = self.consume(TokenType.IDENTIFIER).value
            parameters.append((param_type, param_name))
            
            while self.match(TokenType.COMMA):
                self.advance()
                param_type = self.parse_type()
                param_name = self.consume(TokenType.IDENTIFIER).value
                parameters.append((param_type, param_name))
        
        self.consume(TokenType.RIGHT_PAREN)
        body = self.parse_block()
        
        return FunctionDeclaration(return_type, name, parameters, body)
    
    def parse_variable_declaration(self, var_type: Type, name: str) -> VariableDeclaration:
        """Parse variable declaration"""
        initializer = None
        
        if self.match(TokenType.ASSIGN):
            self.advance()
            initializer = self.parse_expression()
        
        self.consume(TokenType.SEMICOLON)
        return VariableDeclaration(var_type, name, initializer)
    
    def parse_block(self) -> Block:
        """Parse a block statement"""
        self.consume(TokenType.LEFT_BRACE)
        statements = []
        
        while not self.match(TokenType.RIGHT_BRACE) and not self.match(TokenType.EOF):
            self.skip_newlines()
            if self.match(TokenType.RIGHT_BRACE):
                break
            
            stmt = self.parse_statement()
            if stmt:
                statements.append(stmt)
        
        self.consume(TokenType.RIGHT_BRACE)
        return Block(statements)
    
    def parse_statement(self) -> Optional[Statement]:
        """Parse a statement"""
        self.skip_newlines()
        
        if self.match(TokenType.INT, TokenType.FLOAT, TokenType.DOUBLE, TokenType.CHAR, TokenType.BOOL):
            var_type = self.parse_type()
            name = self.consume(TokenType.IDENTIFIER).value
            return self.parse_variable_declaration(var_type, name)
        elif self.match(TokenType.IF):
            return self.parse_if_statement()
        elif self.match(TokenType.WHILE):
            return self.parse_while_statement()
        elif self.match(TokenType.FOR):
            return self.parse_for_statement()
        elif self.match(TokenType.RETURN):
            return self.parse_return_statement()
        elif self.match(TokenType.LEFT_BRACE):
            return self.parse_block()
        else:
            # Expression statement
            expr = self.parse_expression()
            self.consume(TokenType.SEMICOLON)
            return ExpressionStatement(expr)
    
    def parse_if_statement(self) -> IfStatement:
        """Parse if statement"""
        self.consume(TokenType.IF)
        self.consume(TokenType.LEFT_PAREN)
        condition = self.parse_expression()
        self.consume(TokenType.RIGHT_PAREN)
        
        then_stmt = self.parse_statement()
        else_stmt = None
        
        if self.match(TokenType.ELSE):
            self.advance()
            else_stmt = self.parse_statement()
        
        return IfStatement(condition, then_stmt, else_stmt)
    
    def parse_while_statement(self) -> WhileStatement:
        """Parse while statement"""
        self.consume(TokenType.WHILE)
        self.consume(TokenType.LEFT_PAREN)
        condition = self.parse_expression()
        self.consume(TokenType.RIGHT_PAREN)
        body = self.parse_statement()
        
        return WhileStatement(condition, body)
    
    def parse_for_statement(self) -> ForStatement:
        """Parse for statement"""
        self.consume(TokenType.FOR)
        self.consume(TokenType.LEFT_PAREN)
        
        # Init
        init = None
        if not self.match(TokenType.SEMICOLON):
            if self.match(TokenType.INT, TokenType.FLOAT, TokenType.DOUBLE, TokenType.CHAR, TokenType.BOOL):
                var_type = self.parse_type()
                name = self.consume(TokenType.IDENTIFIER).value
                initializer = None
                if self.match(TokenType.ASSIGN):
                    self.advance()
                    initializer = self.parse_expression()
                init = VariableDeclaration(var_type, name, initializer)
            else:
                init = ExpressionStatement(self.parse_expression())
        self.consume(TokenType.SEMICOLON)
        
        # Condition
        condition = None
        if not self.match(TokenType.SEMICOLON):
            condition = self.parse_expression()
        self.consume(TokenType.SEMICOLON)
        
        # Update
        update = None
        if not self.match(TokenType.RIGHT_PAREN):
            update = self.parse_expression()
        self.consume(TokenType.RIGHT_PAREN)
        
        body = self.parse_statement()
        
        return ForStatement(init, condition, update, body)
    
    def parse_return_statement(self) -> ReturnStatement:
        """Parse return statement"""
        self.consume(TokenType.RETURN)
        expression = None
        
        if not self.match(TokenType.SEMICOLON):
            expression = self.parse_expression()
        
        self.consume(TokenType.SEMICOLON)
        return ReturnStatement(expression)
    
    def parse_expression(self) -> Expression:
        """Parse expression with assignment"""
        expr = self.parse_logical_or()
        
        if self.match(TokenType.ASSIGN):
            self.advance()
            value = self.parse_expression()
            if isinstance(expr, Identifier):
                return Assignment(expr, value)
            else:
                raise SyntaxError("Invalid assignment target")
        
        return expr
    
    def parse_logical_or(self) -> Expression:
        """Parse logical OR expression"""
        expr = self.parse_logical_and()
        
        while self.match(TokenType.LOGICAL_OR):
            operator = self.advance().value
            right = self.parse_logical_and()
            expr = BinaryOperation(expr, operator, right)
        
        return expr
    
    def parse_logical_and(self) -> Expression:
        """Parse logical AND expression"""
        expr = self.parse_equality()
        
        while self.match(TokenType.LOGICAL_AND):
            operator = self.advance().value
            right = self.parse_equality()
            expr = BinaryOperation(expr, operator, right)
        
        return expr
    
    def parse_equality(self) -> Expression:
        """Parse equality expression"""
        expr = self.parse_comparison()
        
        while self.match(TokenType.EQUALS, TokenType.NOT_EQUALS):
            operator = self.advance().value
            right = self.parse_comparison()
            expr = BinaryOperation(expr, operator, right)
        
        return expr
    
    def parse_comparison(self) -> Expression:
        """Parse comparison expression"""
        expr = self.parse_addition()
        
        while self.match(TokenType.LESS_THAN, TokenType.GREATER_THAN, 
                         TokenType.LESS_EQUAL, TokenType.GREATER_EQUAL):
            operator = self.advance().value
            right = self.parse_addition()
            expr = BinaryOperation(expr, operator, right)
        
        return expr
    
    def parse_addition(self) -> Expression:
        """Parse addition/subtraction expression"""
        expr = self.parse_shift()
        
        while self.match(TokenType.PLUS, TokenType.MINUS):
            operator = self.advance().value
            right = self.parse_shift()
            expr = BinaryOperation(expr, operator, right)
        
        return expr
    
    def parse_shift(self) -> Expression:
        """Parse shift expression (for cout <<)"""
        expr = self.parse_multiplication()
        
        while self.match(TokenType.LEFT_SHIFT):
            operator = self.advance().value
            right = self.parse_multiplication()
            expr = BinaryOperation(expr, operator, right)
        
        return expr
    
    def parse_multiplication(self) -> Expression:
        """Parse multiplication/division expression"""
        expr = self.parse_unary()
        
        while self.match(TokenType.MULTIPLY, TokenType.DIVIDE, TokenType.MODULO):
            operator = self.advance().value
            right = self.parse_unary()
            expr = BinaryOperation(expr, operator, right)
        
        return expr
    
    def parse_unary(self) -> Expression:
        """Parse unary expression"""
        if self.match(TokenType.LOGICAL_NOT, TokenType.MINUS, TokenType.PLUS):
            operator = self.advance().value
            expr = self.parse_unary()
            return UnaryOperation(operator, expr)
        
        return self.parse_postfix()
    
    def parse_postfix(self) -> Expression:
        """Parse postfix expression"""
        expr = self.parse_primary()
        
        while True:
            if self.match(TokenType.LEFT_PAREN):
                # Function call
                self.advance()
                arguments = []
                
                if not self.match(TokenType.RIGHT_PAREN):
                    arguments.append(self.parse_expression())
                    while self.match(TokenType.COMMA):
                        self.advance()
                        arguments.append(self.parse_expression())
                
                self.consume(TokenType.RIGHT_PAREN)
                
                if isinstance(expr, Identifier):
                    expr = FunctionCall(expr.name, arguments)
                else:
                    raise SyntaxError("Invalid function call")
            elif self.match(TokenType.INCREMENT, TokenType.DECREMENT):
                operator = self.advance().value
                expr = UnaryOperation(operator + "_post", expr)
            else:
                break
        
        return expr
    
    def parse_primary(self) -> Expression:
        """Parse primary expression"""
        if self.match(TokenType.INTEGER_LITERAL):
            value = int(self.advance().value)
            return Literal(value, "int")
        elif self.match(TokenType.FLOAT_LITERAL):
            value = float(self.advance().value)
            return Literal(value, "float")
        elif self.match(TokenType.STRING_LITERAL):
            value = self.advance().value
            return Literal(value, "string")
        elif self.match(TokenType.CHAR_LITERAL):
            value = self.advance().value
            return Literal(value, "char")
        elif self.match(TokenType.TRUE):
            self.advance()
            return Literal(True, "bool")
        elif self.match(TokenType.FALSE):
            self.advance()
            return Literal(False, "bool")
        elif self.match(TokenType.IDENTIFIER):
            name = self.advance().value
            return Identifier(name)
        elif self.match(TokenType.STD_COUT):
            name = self.advance().value
            return Identifier(name)
        elif self.match(TokenType.STD_ENDL):
            name = self.advance().value
            return Identifier(name)
        elif self.match(TokenType.STD_STRING):
            name = self.advance().value
            return Identifier(name)
        elif self.match(TokenType.LEFT_PAREN):
            self.advance()
            expr = self.parse_expression()
            self.consume(TokenType.RIGHT_PAREN)
            return expr
        
        raise SyntaxError(f"Unexpected token: {self.current_token().type.name}")

def main():
    """Test the parser with sample C++ code"""
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
    
    print("AST:")
    print(ast)

if __name__ == "__main__":
    main()