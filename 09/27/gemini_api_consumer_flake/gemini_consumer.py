import os
import google.generativeai as genai

def main():
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        print("Error: GEMINI_API_KEY environment variable not set.")
        return

    genai.configure(api_key=api_key)

    # For now, a simple text generation example
    model = genai.GenerativeModel('gemini-pro')

    try:
        print("\n--- Interacting with Gemini API ---")
        response = model.generate_content("Tell me a short, creative story about a Nix flake that becomes self-aware.")
        print("Gemini's response:")
        print(response.text)
        print("\n--- Gemini API Interaction Complete ---")
    except Exception as e:
        print(f"Error interacting with Gemini API: {e}")

if __name__ == "__main__":
    main()

