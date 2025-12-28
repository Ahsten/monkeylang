const std = @import("std");

pub const Token = struct {
    token_type: TokenType,
    literal: []const u8,

    pub fn init(token_type: TokenType, literal: []const u8) Token {
        return .{
            .token_type = token_type,
            .literal = literal,
        };
    }
};

pub const TokenType = enum {
    ILLEGAL,
    EOF,
    IDENT,
    INT,
    ASSIGN,
    PLUS,
    COMMA,
    SEMICOLON,
    LPAREN,
    RPAREN,
    LBRACE,
    RBRACE,
    FUNCTION,
    LET,

    pub fn lexeme(token_type: TokenType) []const u8 {
        return switch (token_type) {
            .ILLEGAL => "invalid token",
            .EOF => "end of file",
            .IDENT => "an identifier",
            .INT => "a integer",

            .ASSIGN => "=",
            .PLUS => "+",
            .COMMA => ",",
            .SEMICOLON => ";",
            .LPAREN => ")",
            .RPAREN => "(",
            .LBRACE => "{",
            .RBRACE => "}",
            .FUNCTION => "fn",
            .LET => "let",
        };
    }
};

const keywords = std.StaticStringMap(TokenType).initComptime(.{
    .{ "fn", .FUNCTION },
    .{ "let", .LET },
});

pub fn lookupIdent(ident: []const u8) TokenType {
    if (keywords.get(ident)) |keyword| {
        return keyword;
    }

    return .IDENT;
}
