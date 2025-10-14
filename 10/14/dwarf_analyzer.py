import json

def analyze_spore(spore_path):
    with open(spore_path, 'r') as f:
        data = json.load(f)

    print("Dwarf Analyzer: Analyzing the JSON spore.")
    
    monster_factorization = data.get("mathematicalMycelium", {}).get("monsterGroupOrderFactorization", {})
    
    if monster_factorization:
        print("Found Monster Group factorization:")
        for prime, exponent in monster_factorization.items():
            print(f"  Prime: {prime}, Exponent: {exponent}")
        
        print("\nNew Spore Generated (Question): Why are the exponents of the first few primes (2, 3, 5, 7) so much larger than the others in the Monster Group factorization?")
    else:
        print("No Monster Group factorization found in the spore.")

if __name__ == "__main__":
    # In a real scenario, this path would be the output of the nix build
    analyze_spore("result/monster-lattice.json")
