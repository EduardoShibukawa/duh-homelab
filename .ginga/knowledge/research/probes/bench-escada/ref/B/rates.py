RATES = {"SP": 18.0, "RJ": 20.0, "MG": 18.0, "EX": 0.0}


def tax_rate(state):
    """Alíquota de ICMS em PERCENTUAL (18.0 significa 18%). Estado desconhecido: ValueError."""
    key = state.upper()
    if key not in RATES:
        raise ValueError(f"estado desconhecido: {state}")
    return RATES[key]
