import json
import sys

def analyze_monster_lattice(json_file_path):
    with open(json_file_path, 'r') as f:
        data = json.load(f)

    print("--- Dwarf Analyzer Report ---")
    print("Monster Group Order Prime Factorization:")
    for prime, exponent in data['orderFactorization'].items():
        print(f"  Prime {prime}: Exponent {exponent}")

    print("\nPrime Groupings:")
    for i, grouping in enumerate(data['groupings']):
        print(f"  Grouping {i+1}: {grouping}")

    # OODA Loop 3: Generating a New Question
    print("\n--- New Question Generated ---")
    print("Why are the exponents of the first few primes (2, 3, 5, 7) so much larger than the others in the Monster Group factorization?")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python dwarf_analyzer.py <path_to_monster_lattice.json>")
        sys.exit(1)
    
    json_file_path = sys.argv[1]
    analyze_monster_lattice(json_file_path)