"""
C++ Lexical Analyzer (Lexer)
This module tokenizes C++ source code into meaningful tokens.
"""

import re
from enum import Enum, auto
from typing import List, NamedTuple, Optional

class TokenType(Enum):
    # Keywords
    INT = auto()
    FLOAT = auto()
    DOUBLE = auto()
    CHAR = auto()
    BOOL = auto()
    VOID = auto()
    LONG = auto()
    SHORT = auto()
    UNSIGNED = auto()
    SIGNED = auto()
    IF = auto()
    ELSE = auto()
    WHILE = auto()
    FOR = auto()
    RETURN = auto()
    BREAK = auto()
    CONTINUE = auto()
    DO = auto()
    TRUE = auto()
    FALSE = auto()
    INCLUDE = auto()
    IOSTREAM = auto()
    NAMESPACE = auto()
    STD = auto()
    USING = auto()
    STD_COUT = auto()
    STD_ENDL = auto()
    STD_STRING = auto()
    CLASS = auto()
    STRUCT = auto()
    CONST = auto()
    ENUM = auto()
    AUTO = auto()
    NEW = auto()
    DELETE = auto()
    SWITCH = auto()
    CASE = auto()
    DEFAULT = auto()
    NULLPTR = auto()
    
    # Literals
    INTEGER_LITERAL = auto()
    FLOAT_LITERAL = auto()
    STRING_LITERAL = auto()
    CHAR_LITERAL = auto()
    
    # Identifiers
    IDENTIFIER = auto()
    
    # Operators
    PLUS = auto()
    MINUS = auto()
    MULTIPLY = auto()
    DIVIDE = auto()
    MODULO = auto()
    ASSIGN = auto()
    EQUALS = auto()
    NOT_EQUALS = auto()
    LESS_THAN = auto()
    GREATER_THAN = auto()
    LESS_EQUAL = auto()
    GREATER_EQUAL = auto()
    LOGICAL_AND = auto()
    LOGICAL_OR = auto()
    LOGICAL_NOT = auto()
    INCREMENT = auto()
    DECREMENT = auto()
    LEFT_SHIFT = auto()
    AMPERSAND = auto()
    
    # Punctuation
    SEMICOLON = auto()
    COMMA = auto()
    LEFT_PAREN = auto()
    RIGHT_PAREN = auto()
    LEFT_BRACE = auto()
    RIGHT_BRACE = auto()
    LEFT_BRACKET = auto()
    RIGHT_BRACKET = auto()
    DOT = auto()
    COLON = auto()
    ARROW = auto()
    SCOPE_RESOLUTION = auto()
    
    # Preprocessor
    HASH = auto()
    
    # Special
    NEWLINE = auto()
    WHITESPACE = auto()
    EOF = auto()
    UNKNOWN = auto()

class Token(NamedTuple):
    type: TokenType
    value: str
    line: int
    column: int

class Lexer:
    def __init__(self, source_code: str):
        self.source_code = source_code
        self.position = 0
        self.line = 1
        self.column = 1
        
        # Keywords mapping
        self.keywords = {
            'int': TokenType.INT,
            'float': TokenType.FLOAT,
            'double': TokenType.DOUBLE,
            'char': TokenType.CHAR,
            'bool': TokenType.BOOL,
            'void': TokenType.VOID,
            'long': TokenType.LONG,
            'short': TokenType.SHORT,
            'unsigned': TokenType.UNSIGNED,
            'signed': TokenType.SIGNED,
            'if': TokenType.IF,
            'else': TokenType.ELSE,
            'while': TokenType.WHILE,
            'for': TokenType.FOR,
            'return': TokenType.RETURN,
            'break': TokenType.BREAK,
            'continue': TokenType.CONTINUE,
            'do': TokenType.DO,
            'true': TokenType.TRUE,
            'false': TokenType.FALSE,
            'include': TokenType.INCLUDE,
            'iostream': TokenType.IOSTREAM,
            'namespace': TokenType.NAMESPACE,
            'std': TokenType.STD,
            'using': TokenType.USING,
            'class': TokenType.CLASS,
            'struct': TokenType.STRUCT,
            'const': TokenType.CONST,
            'enum': TokenType.ENUM,
            'auto': TokenType.AUTO,
            'new': TokenType.NEW,
            'delete': TokenType.DELETE,
            'switch': TokenType.SWITCH,
            'case': TokenType.CASE,
            'default': TokenType.DEFAULT,
            'nullptr': TokenType.NULLPTR,
        }
        
        # Single character tokens
        self.single_char_tokens = {
            '+': TokenType.PLUS,
            '-': TokenType.MINUS,
            '*': TokenType.MULTIPLY,
            '/': TokenType.DIVIDE,
            '%': TokenType.MODULO,
            '=': TokenType.ASSIGN,
            '<': TokenType.LESS_THAN,
            '>': TokenType.GREATER_THAN,
            '!': TokenType.LOGICAL_NOT,
            ';': TokenType.SEMICOLON,
            ',': TokenType.COMMA,
            '(': TokenType.LEFT_PAREN,
            ')': TokenType.RIGHT_PAREN,
            '{': TokenType.LEFT_BRACE,
            '}': TokenType.RIGHT_BRACE,
            '[': TokenType.LEFT_BRACKET,
            ']': TokenType.RIGHT_BRACKET,
            '.': TokenType.DOT,
            '#': TokenType.HASH,
            '&': TokenType.AMPERSAND,
            ':': TokenType.COLON,
        }
    
    def current_char(self) -> Optional[str]:
        """Get the current character or None if at end"""
        if self.position >= len(self.source_code):
            return None
        return self.source_code[self.position]
    
    def peek_char(self, offset: int = 1) -> Optional[str]:
        """Peek at a character ahead"""
        peek_pos = self.position + offset
        if peek_pos >= len(self.source_code):
            return None
        return self.source_code[peek_pos]
    
    def advance(self) -> None:
        """Move to the next character"""
        if self.position < len(self.source_code):
            if self.current_char() == '\n':
                self.line += 1
                self.column = 1
            else:
                self.column += 1
            self.position += 1
    
    def skip_whitespace(self) -> None:
        """Skip whitespace characters except newlines"""
        while self.current_char() and self.current_char() in ' \t\r':
            self.advance()
    
    def skip_comment(self) -> None:
        """Skip single-line (//) and multi-line (/* */) comments"""
        if self.current_char() == '/' and self.peek_char() == '/':
            # Single-line comment
            while self.current_char() and self.current_char() != '\n':
                self.advance()
        elif self.current_char() == '/' and self.peek_char() == '*':
            # Multi-line comment
            self.advance()  # Skip '/'
            self.advance()  # Skip '*'
            while self.current_char():
                if self.current_char() == '*' and self.peek_char() == '/':
                    self.advance()  # Skip '*'
                    self.advance()  # Skip '/'
                    break
                self.advance()
    
    def read_string_literal(self) -> str:
        """Read a string literal"""
        quote_char = self.current_char()  # " or '
        value = quote_char
        self.advance()
        
        while self.current_char() and self.current_char() != quote_char:
            if self.current_char() == '\\':
                value += self.current_char()
                self.advance()
                if self.current_char():
                    value += self.current_char()
                    self.advance()
            else:
                value += self.current_char()
                self.advance()
        
        if self.current_char() == quote_char:
            value += self.current_char()
            self.advance()
        
        return value
    
    def read_number(self) -> tuple[str, TokenType]:
        """Read a numeric literal"""
        value = ''
        token_type = TokenType.INTEGER_LITERAL
        
        while self.current_char() and (self.current_char().isdigit() or self.current_char() == '.'):
            if self.current_char() == '.':
                token_type = TokenType.FLOAT_LITERAL
            value += self.current_char()
            self.advance()
        
        return value, token_type
    
    def read_identifier(self) -> str:
        """Read an identifier or keyword"""
        value = ''
        while (self.current_char() and 
               (self.current_char().isalnum() or self.current_char() == '_')):
            value += self.current_char()
            self.advance()
        return value
    
    def tokenize(self) -> List[Token]:
        """Tokenize the entire source code"""
        tokens = []
        
        while self.current_char():
            start_line = self.line
            start_column = self.column
            
            # Skip whitespace
            if self.current_char() in ' \t\r':
                self.skip_whitespace()
                continue
            
            # Handle newlines
            if self.current_char() == '\n':
                tokens.append(Token(TokenType.NEWLINE, '\n', start_line, start_column))
                self.advance()
                continue
            
            # Handle comments
            if self.current_char() == '/' and self.peek_char() in ['/', '*']:
                self.skip_comment()
                continue
            
            # Handle string literals
            if self.current_char() in ['"', "'"]:
                value = self.read_string_literal()
                token_type = TokenType.STRING_LITERAL if value.startswith('"') else TokenType.CHAR_LITERAL
                tokens.append(Token(token_type, value, start_line, start_column))
                continue
            
            # Handle numbers
            if self.current_char().isdigit():
                value, token_type = self.read_number()
                tokens.append(Token(token_type, value, start_line, start_column))
                continue
            
            # Handle identifiers and keywords
            if self.current_char().isalpha() or self.current_char() == '_':
                value = self.read_identifier()
                # Special handling for std:: qualified identifiers
                if value == 'std' and self.current_char() == ':' and self.peek_char() == ':':
                    # Read std::
                    self.advance()  # Skip first :
                    self.advance()  # Skip second :
                    # Read the identifier after ::
                    if self.current_char() and (self.current_char().isalpha() or self.current_char() == '_'):
                        std_id = self.read_identifier()
                        full_value = f"std::{std_id}"
                        # Map common std library identifiers
                        if std_id == 'cout':
                            tokens.append(Token(TokenType.STD_COUT, full_value, start_line, start_column))
                        elif std_id == 'endl':
                            tokens.append(Token(TokenType.STD_ENDL, full_value, start_line, start_column))
                        elif std_id == 'string':
                            tokens.append(Token(TokenType.STD_STRING, full_value, start_line, start_column))
                        else:
                            tokens.append(Token(TokenType.IDENTIFIER, full_value, start_line, start_column))
                    else:
                        # Just std:: without identifier
                        tokens.append(Token(TokenType.STD, value, start_line, start_column))
                        tokens.append(Token(TokenType.SCOPE_RESOLUTION, '::', start_line, start_column))
                else:
                    token_type = self.keywords.get(value, TokenType.IDENTIFIER)
                    tokens.append(Token(token_type, value, start_line, start_column))
                continue
            
            # Handle two-character operators
            two_char = self.current_char() + (self.peek_char() or '')
            if two_char == '==':
                tokens.append(Token(TokenType.EQUALS, '==', start_line, start_column))
                self.advance()
                self.advance()
                continue
            elif two_char == '!=':
                tokens.append(Token(TokenType.NOT_EQUALS, '!=', start_line, start_column))
                self.advance()
                self.advance()
                continue
            elif two_char == '<=':
                tokens.append(Token(TokenType.LESS_EQUAL, '<=', start_line, start_column))
                self.advance()
                self.advance()
                continue
            elif two_char == '>=':
                tokens.append(Token(TokenType.GREATER_EQUAL, '>=', start_line, start_column))
                self.advance()
                self.advance()
                continue
            elif two_char == '&&':
                tokens.append(Token(TokenType.LOGICAL_AND, '&&', start_line, start_column))
                self.advance()
                self.advance()
                continue
            elif two_char == '||':
                tokens.append(Token(TokenType.LOGICAL_OR, '||', start_line, start_column))
                self.advance()
                self.advance()
                continue
            elif two_char == '++':
                tokens.append(Token(TokenType.INCREMENT, '++', start_line, start_column))
                self.advance()
                self.advance()
                continue
            elif two_char == '--':
                tokens.append(Token(TokenType.DECREMENT, '--', start_line, start_column))
                self.advance()
                self.advance()
                continue
            elif two_char == '->':
                tokens.append(Token(TokenType.ARROW, '->', start_line, start_column))
                self.advance()
                self.advance()
                continue
            elif two_char == '::':
                tokens.append(Token(TokenType.SCOPE_RESOLUTION, '::', start_line, start_column))
                self.advance()
                self.advance()
                continue
            elif two_char == '<<':
                tokens.append(Token(TokenType.LEFT_SHIFT, '<<', start_line, start_column))
                self.advance()
                self.advance()
                continue
            
            # Handle single character tokens
            if self.current_char() in self.single_char_tokens:
                token_type = self.single_char_tokens[self.current_char()]
                tokens.append(Token(token_type, self.current_char(), start_line, start_column))
                self.advance()
                continue
            
            # Unknown character
            tokens.append(Token(TokenType.UNKNOWN, self.current_char(), start_line, start_column))
            self.advance()
        
        # Add EOF token
        tokens.append(Token(TokenType.EOF, '', self.line, self.column))
        return tokens

def main():
    """Test the lexer with sample C++ code"""
    sample_code = """
#include <iostream>
using namespace std;

int main() {
    int x = 10;
    float y = 3.14;
    cout << "Hello World!" << endl;
    return 0;
}
"""
    
    lexer = Lexer(sample_code)
    tokens = lexer.tokenize()
    
    print("Tokens:")
    for token in tokens:
        if token.type not in [TokenType.WHITESPACE, TokenType.NEWLINE]:
            print(f"{token.type.name}: {repr(token.value)} at ({token.line}, {token.column})")

if __name__ == "__main__":
    main()