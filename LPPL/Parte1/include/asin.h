/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_ASIN_H_INCLUDED
# define YY_YY_ASIN_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    STRUCT_ = 258,
    INT_ = 259,
    BOOL_ = 260,
    TRUE_ = 261,
    FALSE_ = 262,
    READ_ = 263,
    PRINT_ = 264,
    IF_ = 265,
    ELSE_ = 266,
    WHILE_ = 267,
    MAS_ = 268,
    MENOS_ = 269,
    POR_ = 270,
    DIV_ = 271,
    MOD_ = 272,
    INC_ = 273,
    DEC_ = 274,
    ASIG_ = 275,
    MASASIG_ = 276,
    MENOSASIG_ = 277,
    PORASIG_ = 278,
    DIVASIG_ = 279,
    IGUAL_ = 280,
    DESIGUAL_ = 281,
    MAYOR_ = 282,
    MENOR_ = 283,
    MAYORIGUAL_ = 284,
    MENORIGUAL_ = 285,
    AND_ = 286,
    OR_ = 287,
    NEG_ = 288,
    OB_ = 289,
    CB_ = 290,
    OSB_ = 291,
    CSB_ = 292,
    OCB_ = 293,
    CCB_ = 294,
    DOT_ = 295,
    SC_ = 296,
    ID_ = 297,
    CTE_ = 298
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_ASIN_H_INCLUDED  */
