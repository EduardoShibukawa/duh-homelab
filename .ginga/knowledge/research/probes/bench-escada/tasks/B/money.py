def to_cents(amount):
    """Converte um valor em reais (float, int ou str como '19.99') para centavos inteiros,
    arredondando meio-para-cima (2.675 -> 268 centavos)."""
    return int(float(amount) * 100)


def from_cents(cents):
    """Formata centavos inteiros como 'RRR.CC'."""
    return f"{cents // 100}.{cents % 100:02d}"
