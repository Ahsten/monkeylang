const std = @import("std");
const Token = @import("token.zig").Token;
const TokenType = @import("token.zig").TokenType;
const lookupIdent = @import("token.zig").lookupIdent;
const testing = std.testing;

pub const Lexer = struct {
    input: []const u8,
    position: usize,
    readPosition: usize,
    ch: u8,

    pub fn init(input: []const u8) Lexer {
        return .{
            .input = input,
            .position = 0,
            .readPosition = 1,
            .ch = input[0],
        };
    }

    pub fn nextToken(self: *Lexer) Token {
        self.skipWhitespace();

        const tok = switch (self.ch) {
            '=' => newToken(TokenType.ASSIGN, TokenType.ASSIGN.lexeme()),
            ';' => newToken(TokenType.SEMICOLON, TokenType.SEMICOLON.lexeme()),
            '(' => newToken(TokenType.LPAREN, TokenType.LPAREN.lexeme()),
            ')' => newToken(TokenType.RPAREN, TokenType.RPAREN.lexeme()),
            ',' => newToken(TokenType.COMMA, TokenType.COMMA.lexeme()),
            '+' => newToken(TokenType.PLUS, TokenType.PLUS.lexeme()),
            '{' => newToken(TokenType.LBRACE, TokenType.LBRACE.lexeme()),
            '}' => newToken(TokenType.RBRACE, TokenType.RBRACE.lexeme()),
            'a'...'z', 'A'...'Z' => {
                const ident = self.readIdentifier();
                const token_type = lookupIdent(ident);
                return newToken(token_type, ident);
            },
            '0'...'9' => {
                const number = self.readNumber();
                return newToken(TokenType.INT, number);
            },
            0 => newToken(TokenType.EOF, ""),
            else => unreachable,
        };
        self.readChar();
        return tok;
    }

    fn newToken(token_type: TokenType, ch: []const u8) Token {
        return Token.init(token_type, ch);
    }

    fn readChar(self: *Lexer) void {
        if (self.readPosition >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.readPosition];
        }
        self.position = self.readPosition;
        self.readPosition += 1;
    }

    fn readIdentifier(self: *Lexer) []const u8 {
        const start = self.position;
        while (isLetter(self.ch)) {
            self.readChar();
        }
        return self.input[start..self.position];
    }

    fn readNumber(self: *Lexer) []const u8 {
        const start = self.position;
        while (isDigit(self.ch)) {
            self.readChar();
        }
        return self.input[start..self.position];
    }

    fn skipWhitespace(self: *Lexer) void {
        while (self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r') {
            self.readChar();
        }
    }

    fn isLetter(ch: u8) bool {
        return (ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z') or ch == '_';
    }

    fn isDigit(ch: u8) bool {
        return ch >= '0' and ch <= '9';
    }
};

test "nextToken" {
    const input =
        \\let five = 5;
        \\let ten = 10;
        \\
        \\let add = fn(x, y) {
        \\  x + y;    
        \\};
        \\
        \\let result = add(five, ten);
    ;
    try testLexer(input, &.{
        .LET,
        .IDENT,
        .ASSIGN,
        .INT,
        .SEMICOLON,
        .LET,
        .IDENT,
        .ASSIGN,
        .INT,
        .SEMICOLON,
        .LET,
        .IDENT,
        .ASSIGN,
        .FUNCTION,
        .LPAREN,
        .IDENT,
        .COMMA,
        .IDENT,
        .RPAREN,
        .LBRACE,
        .IDENT,
        .PLUS,
        .IDENT,
        .SEMICOLON,
        .RBRACE,
        .SEMICOLON,
        .LET,
        .IDENT,
        .ASSIGN,
        .IDENT,
        .LPAREN,
        .IDENT,
        .COMMA,
        .IDENT,
        .RPAREN,
        .SEMICOLON,
    });
}

fn testLexer(source: []const u8, expected_token_types: []const TokenType) !void {
    var lexer = Lexer.init(source);
    for (expected_token_types) |expected_token_type| {
        const token = lexer.nextToken();
        try testing.expectEqual(expected_token_type, token.token_type);
    }

    const last_token = lexer.nextToken();
    try testing.expectEqual(TokenType.EOF, last_token.token_type);
}
