%{ 
#include<stdio.h>
#include<string.h>
#include<iostream>
#include<set>
#include<map>

using namespace std;

set<char> states, alphabet;
multimap<char,string> rules;

char startsymbol, nonterminal;

bool syntax = false, semantic = false;

%}

%s ALPHABET STATE SEPARATOR NONTERMINAL REPLACEMENT START_SYMBOL BEGIN_ALPHABET BEGIN_PRODUCTION_RULES

lower-case-letter	[a-df-z]
digit			[0-9]
vid			"e"
other			"'"|"-"|"="|"["|"]"|";"|"`"|"\\"|"."|"/"|"~"|"!"|"@"|"#"|"$"|"%"|"^"|"&"|"*"|"-"|"+"|":"|"\""|"|"|"<"|">"|"?"|"_"

terminal		{lower-case-letter}|{digit}|{other}
alphabet		{terminal}+?
word			{vid}|{terminal}+

upper-case-letter	[A-Z]
start-symbol		{upper-case-letter}
replacement		{vid}|{state}+




production-rule		\({whitespace}{nonterminal}{whitespace},{whitespace}{replacement}{whitespace}\)
production-rules	{production-rule}+?
nonterminal		{upper-case-letter}
state			{nonterminal}|{terminal}
states			{state}+

whitespace		[ \t\r\n]*


%%
<INITIAL>
	{whitespace}"("{whitespace}"{"{whitespace} {
		BEGIN(STATE);
	}
			
<STATE>{
	{state}{whitespace}"}"{whitespace}","{whitespace} {
		states.insert(yytext[0]);
		BEGIN(BEGIN_ALPHABET);
	}
	
	{state}{whitespace}","{whitespace}	{	
		states.insert(yytext[0]);
	}
}

<BEGIN_ALPHABET>{
	"{"{whitespace}"}"{whitespace}","{whitespace} {
		BEGIN(BEGIN_PRODUCTION_RULES);
	}
	"{"{whitespace} {
		BEGIN(ALPHABET);
	}
}
		
<ALPHABET>{
	{terminal}{whitespace}","{whitespace} 	{
		alphabet.insert(yytext[0]);
	}
	
	{terminal}{whitespace}"}"{whitespace}","{whitespace} {
		alphabet.insert(yytext[0]);
		BEGIN(BEGIN_PRODUCTION_RULES);
	}
}

<BEGIN_PRODUCTION_RULES>{
	"{"{whitespace}"("{whitespace} {
		BEGIN(NONTERMINAL);
	}
	"{"{whitespace}"}"{whitespace}","{whitespace} {
		BEGIN(START_SYMBOL);
	}
}
	
<NONTERMINAL>
	{nonterminal}{whitespace}","{whitespace} {
		nonterminal = yytext[0];
		BEGIN(REPLACEMENT);
	}

<REPLACEMENT>{
	{replacement} {
		rules.emplace(nonterminal, yytext);
		BEGIN(SEPARATOR);
	}
}

<SEPARATOR>{
	{whitespace}")"{whitespace}","{whitespace}"("{whitespace} {
		BEGIN(NONTERMINAL);
	}
	{whitespace}")"{whitespace}"}"{whitespace}","{whitespace} {
		BEGIN(START_SYMBOL);
	}
}
	
<START_SYMBOL>
	{start-symbol}{whitespace}")"{whitespace} {
			startsymbol = yytext[0];
	}	
	
	. {
		fprintf(stderr,"Syntax error\n");
		syntax = true;
		return 0;
	}
%%

bool has_e() {
	set<char> s;
	int elems = 0;
	bool empty;
	s.insert('e');
	while(s.size() != elems) {
		elems = s.size();
		for(auto it : rules) {
			if(s.find(it.first) == s.end()) {
				empty = true;
				for(int i=0;i<it.second.length();i++) {
					if(s.find(it.second[i]) == s.end()) {
						empty = false;
						break;
					}
				}
				if(empty) {
					if(it.first == startsymbol) {
						return true;
					}
					else {
						s.insert(it.first);
					}
				}
			}
		}
	}
	return false; 
}

void useless_nonterminals(bool all) {
	set<char> s;
	int elems = -1;
	bool useful;
	while(s.size() != elems) {
		elems = s.size();
		for(auto it : rules) {
			if(s.find(it.first) == s.end()) {
				useful = true;
				for(int i=0;i<it.second.length();i++) {
					if(isupper(it.second[i]) && s.find(it.second[i]) == s.end()) {
						useful = false;
						break;
					}
				}
				if(useful) {
					s.insert(it.first);
				}
			}
		}
	}
	if(all) {
		for(auto it : states) {
			if(isupper(it) && s.find(it) == s.end()) {
				cout<<it<<"\n";
			}
		}
	}
	else {
		if(s.find(startsymbol) == s.end()) {
			cout<<"Yes";
		}
		else {
			cout<<"No";
		}
	}
}

int main(int argc, char **argv) {
	if((argc != 2) || (strcmp(argv[1], "--is-void") != 0 && strcmp(argv[1], "--has-e") != 0 && strcmp(argv[1], "--useless-nonterminals") != 0)) {
		fprintf(stderr, "Argument error\n");
		return 0;
	}
	FILE* f = fopen("grammar", "rt");
   yyrestart(f);
	yylex();
	
	if(!syntax) {
		//toti terminalii se afla in V
		for(auto it : alphabet) {
			if(states.find(it) == states.end()) {
				semantic = true;
				break;
			}
		}
		//toti terminalii din V sunt in E
		if(!semantic) {
			for(auto it : states) {
				if(!isupper(it) && alphabet.find(it) == alphabet.end()) {
					semantic = true;
					break;
				}
			}
		}
		//simbolul de start se afla in V si este neterminal
		if(!semantic && isupper(startsymbol) && states.find(startsymbol) == states.end())
			semantic = true;
	
		//partea stanga si partea dreapta a unei reguli se afla in V
		for(auto it : rules) {
			//partea stanga
			if(states.find(it.first) == states.end()) {
				semantic = true;
			}
			//partea dreapta
			if(it.second[0] != 'e') {
				for(int i = 0;i<it.second.length();i++) {
					if(states.find(it.second[i]) == states.end()) {
						semantic = true;
					}
				}
			}
			if(semantic)
				break;
		}
		if(semantic) {
			fprintf(stderr, "Semantic error\n");
		}
	}
	if(!syntax && !semantic) {
		if(strcmp(argv[1],"--has-e") == 0) {
			if(has_e())
				cout<<"Yes\n";
			else
				cout<<"No\n";
		}
		else if(strcmp(argv[1],"--useless-nonterminals") == 0) {
			useless_nonterminals(true);
		}
		else {
			useless_nonterminals(false);
		}
	}
	
	fclose(f);
	
	return 0;
}
