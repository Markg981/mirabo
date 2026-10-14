#!/usr/bin/env python3
"""Calcolatore di unit economics per coorte (analisi §4.1, §4.4).

Per ogni scenario (prudente, base, ottimista) calcola, per famiglia pagante:
  ricavo netto = prezzo / (1 + IVA) * (1 - commissione effettiva) * (1 - rimborsi)
  margine      = ricavo netto - costi variabili
  contributo   = margine - costo di acquisizione
e il break-even sui costi fissi: famiglie = costi fissi / contributo.

La commissione NON ha un valore predefinito: dipende da mercato, programma e
operazione dello store, quindi va dichiarata in ogni scenario (e verificata
al momento della vendita). Nessuna dipendenza esterna.

Uso:  python studio/economics.py studio/economics_scenarios/esempio.json
      python studio/economics.py --test
"""
import json
import math
import sys
import unittest

REQUIRED = ("vat_rate", "store_fee_rate", "refund_rate", "variable_cost", "acquisition_cost")


def net_revenue(price, vat_rate, store_fee_rate, refund_rate, net_override=None):
    """Ricavo netto per famiglia. `net_override` permette di partire da un netto già noto."""
    if net_override is not None:
        return float(net_override)
    return price / (1 + vat_rate) * (1 - store_fee_rate) * (1 - refund_rate)


def collection_cost(c):
    """Costo completo di una raccolta: `items` voci con i costi per voce (revisione
    pedagogica, traduzione, audio, accessibilità...), più costi una tantum e la
    manutenzione annua per gli anni considerati."""
    n = c.get("items", 1)
    per_item = sum(c.get("per_item", {}).values())
    one_off = sum(c.get("one_off", {}).values())
    upkeep = c.get("yearly_maintenance", 0) * c.get("years", 1)
    return n * per_item + one_off + upkeep


def fixed_costs(s):
    total = sum(s.get("fixed_costs", {}).values())
    for c in s.get("collections", []):
        total += collection_cost(c)
    return total


def analyze(s):
    needed = [k for k in REQUIRED if k not in s]
    if "net_revenue" not in s and "price" not in s:
        needed.append("price")
    if "net_revenue" in s:  # netto già noto: IVA, commissione e rimborsi non servono
        needed = [k for k in needed if k not in ("vat_rate", "store_fee_rate", "refund_rate")]
    if needed:
        raise ValueError(f"scenario '{s.get('name', '?')}': mancano {', '.join(needed)}")
    net = net_revenue(s.get("price", 0), s.get("vat_rate", 0), s.get("store_fee_rate", 0),
                      s.get("refund_rate", 0), s.get("net_revenue"))
    margin = net - s["variable_cost"]
    contribution = margin - s["acquisition_cost"]
    fixed = fixed_costs(s)
    breakeven = math.ceil(fixed / contribution - 1e-9) if contribution > 0 else None
    result = {"name": s.get("name", ""), "net_revenue": net, "margin": margin,
              "contribution": contribution, "fixed_costs": fixed,
              "breakeven_families": breakeven}  # None = non raggiungibile
    if "families" in s:
        result["families"] = s["families"]
        result["profit"] = s["families"] * contribution - fixed
    return result


def load(path):
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    return data["scenarios"] if isinstance(data, dict) else data


def report(results):
    lines = []
    for r in results:
        be = r["breakeven_families"]
        line = (f"[{r['name']}] netto {r['net_revenue']:.2f}  margine {r['margin']:.2f}  "
                f"contributo {r['contribution']:.2f}  costi fissi {r['fixed_costs']:.0f}  "
                f"break-even {be if be is not None else 'non raggiungibile'} famiglie")
        if "profit" in r:
            line += f"  risultato a {r['families']} famiglie {r['profit']:.0f}"
        lines.append(line)
    return "\n".join(lines)


class EconomicsTest(unittest.TestCase):
    def test_esempio_analisi(self):
        # 30 netti, 6 variabili, 12 di acquisizione -> 12 di contributo; 12.000 fissi -> 1.000 famiglie
        r = analyze({"name": "esempio", "net_revenue": 30, "variable_cost": 6,
                     "acquisition_cost": 12, "fixed_costs": {"produzione": 12000}})
        self.assertEqual(r["margin"], 24)
        self.assertEqual(r["contribution"], 12)
        self.assertEqual(r["breakeven_families"], 1000)

    def test_netto_da_prezzo(self):
        self.assertAlmostEqual(net_revenue(12.2, 0.22, 0.15, 0.1), 10 * 0.85 * 0.9)

    def test_contributo_negativo(self):
        r = analyze({"net_revenue": 10, "variable_cost": 5, "acquisition_cost": 8})
        self.assertIsNone(r["breakeven_families"])

    def test_commissione_obbligatoria(self):
        with self.assertRaises(ValueError):
            analyze({"price": 10, "vat_rate": 0.22, "refund_rate": 0,
                     "variable_cost": 1, "acquisition_cost": 1})

    def test_costo_raccolta(self):
        c = {"items": 10, "per_item": {"revisione": 100, "traduzione": 200, "audio": 150,
                                         "accessibilita": 50},
             "one_off": {"illustrazioni": 1000}, "yearly_maintenance": 500, "years": 2}
        self.assertEqual(collection_cost(c), 10 * 500 + 1000 + 1000)

    def test_file_esempio(self):
        import os
        p = os.path.join(os.path.dirname(__file__), "economics_scenarios", "esempio.json")
        self.assertEqual([r["name"] for r in map(analyze, load(p))], ["prudente", "base", "ottimista"])


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--test":
        unittest.main(argv=[sys.argv[0]])
    elif len(sys.argv) > 1:
        print(report([analyze(s) for s in load(sys.argv[1])]))
    else:
        print(__doc__)
