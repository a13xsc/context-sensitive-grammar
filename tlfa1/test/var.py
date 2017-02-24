import sys
import string
import random

MAX_PAD = 10
MAX_RULE_LENGTH = 20

def gen_pool():
    nterm = string.uppercase
    term = string.digits + string.lowercase[0:4] + string.lowercase[6:] +\
            '`-=[];\'\\./~!@#$%^&*_+:"|<>?'
    return list(nterm), list(term)

def pad_str(char):
    len1 = random.randint(0, MAX_PAD)
    len2 = random.randint(0, MAX_PAD)
    return len1 * ' ' + char + len2 * ' '

def gen_right(v, min_len):
    if not v:
        return 'e'
    n = random.randint(min_len, MAX_RULE_LENGTH)
    result = ''.join(random.choice(v) for i in range(0, n))
    if not result:
        result = 'e'
    return result

def make_strict(right, strict):
    u = random.choice(strict)
    index = random.randint(0, len(right) - 1)
    return right[0:index] + u + right[index + 1:]

def gen_set(pool, num):
    random.shuffle(pool)
    result = pool[0:num]
    del pool[0:num]
    return result

def gen_rules(empty, nonempty, useless, sigma, num, ltype):
    rules = {u:set() for u in empty + nonempty + useless}
    firstV = []
    for u in empty:
        rules[u].add(gen_right(firstV, 0))
        firstV.append(u)
    secondV = sigma[:]
    for u in nonempty:
        right = gen_right(secondV,0 if ltype == 0 else 1)
        rules[u].add(right)
        firstV.append(u)
    thirdV = empty + nonempty + useless + sigma
    lists = [l for l in [empty, nonempty, useless] if l]
    k = len(lists)
    for i in range(num):
        right = gen_right(thirdV, 1)
        rule = make_strict(right, lists[i % k])
        rules[random.choice(lists[i % k])].add(rule)
    return rules

def gen_start(empty, nonempty, useless, ltype):
    if ltype == 0:
        return random.choice(useless)
    elif ltype ==1:
        return random.choice(empty)
    else:
        return random.choice(nonempty)

def write_grammar(name, v, sigma, rules, start, pad):
    if pad == 1:
        func = pad_str
    else:
        func = lambda x:x
    with open(name + '.in', 'wt') as f:
        f.write(func('(') + str_set(v, pad) + func(',') +
                str_set(sigma, pad) + func(',') + str_rules(rules, pad) +
                func(',') + start + func(')') + '\n')

def write_useless(name, useless):
    with open(name + '.out', 'wt') as f:
        for u in useless:
            f.write(u + '\n')

def str_set(alphabet, pad):
    random.shuffle(alphabet)
    if pad:
        result = pad_str('{')
        sep = ''
        for c in alphabet:
            result += sep + pad_str(c)
            sep = ','
        result += pad_str('}')
        return result
    else:
        return '{' + ','.join(alphabet) + '}'

def str_rules(rules, pad):
    if pad:
        result = pad_str('{')
        sep = ''
        for l, v in rules.items():
            for r in v:
                result += sep + pad_str('(') + l + pad_str(',') + r + pad_str(')')
                sep = ','
        result += pad_str('}')
        return result
    else:
        return '{' + ','.join(['({},{})'.format(l,r) for l,v in rules.items() for r in v]) + '}'

def check(argv):
    if len(argv) != 9:
        print_usage()
    try:
        usf = int(argv[1])
        usl = int(argv[2])
        ter = int(argv[3])
        rul = int(argv[4])
        pad = int(argv[5])
        ltype = int(argv[6])
    except ValueError:
        print_usage()
    prefix = argv[7]
    name = argv[8]
    if usf + usl == 0 or usf > rul or usl + rul == 0 or usf < 0 or usl < 0 or ter < 0 or rul < 0\
            or (not pad in [0,1]) or (not ltype in [0,1,2]) or (' ' in name):
        print_usage()
    if (usf == 0 or rul == 0) and ltype != 0:
        print 'If <useful> or <rules> are 0, then <type> must also be 0'
        print_usage()
    if ter == 0 and ltype == 2:
        print 'If <terminal> is 0, then <type> must not be 2'
        print_usage()
    if usl == 0 and ltype == 0:
        print 'If <useless> is 0, then <type> must not be 0'
        print_usage()
    return usf, usl, ter, rul, pad, ltype, prefix, name

def print_tests(name, ltype):
    d = {'--is-void':'yes.out' if ltype == 0 else 'no.out',
            '--has-e':'yes.out' if ltype == 1 else 'no.out',
            '--useless-nonterminals': name+'.out'}
    for k,v in d.items():
        print '1 {}.in {} {} empty.err'.format(name, k, v)

def print_usage():
    print """Usage: python var.py <useful> <useless> <terminals> <rules> <pad> <type> <prefix> <name>
    <useful>: number of useful nonterminals
    <useless>: number of useless nonterminals
    <terminals>: number of terminals
    <rules>: number of rules>
    <pad>: 0 if there should be no padding, 1 if there should be
    <type>:
        - 0 if the language must be the empty set,
        - 1 if the language must contain the empty string,
        - 2 if the language must not be empty or contain the empty string
    <prefix>: directory where the files will be generated
    <name>: name of the generated file. <name>.in will contain the grammar description,\
<name>.out will contain the useless nonterminals
Restrictions:
    - <useful> + <useless> != 0
    - <useful> <= <rules>
    - <useless> + <rules> != 0
    - <name> must not contain spaces
    - <useful>, <uselesS>, <terminals>, <rules> >= 0"""
    sys.exit(1)

if __name__ == '__main__':
    usf, usl, ter, rul, pad, ltype, prefix, name = check(sys.argv)
    npool, tpool = gen_pool()
    empty = gen_set(npool, usf/2)
    nonempty = gen_set(npool, usf - usf/2)
    if ltype == 1 or ter == 0:
        empty, nonempty = nonempty,empty
    useless = gen_set(npool, usl)
    sigma = gen_set(tpool, ter)
    rules = gen_rules(empty, nonempty, useless, sigma, rul-usf, ltype)
    v = empty + nonempty + useless + sigma
    start = gen_start(empty, nonempty, useless, ltype)
    write_grammar(prefix + name, v, sigma, rules, start, pad)
    write_useless(prefix + name, useless)
    print_tests(name, ltype)
