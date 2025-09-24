import requests
from bs4 import BeautifulSoup
from urllib.parse import urlparse
import json
import sys
import os

def fetch_and_parse(url):
    """Fetches content from a URL and extracts main text."""
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()  # Raise an exception for HTTP errors
        soup = BeautifulSoup(response.text, 'html.parser')

        # Try to find main content areas
        main_content = soup.find('main') or soup.find('article') or soup.find('body')
        if main_content:
            text = main_content.get_text(separator=' ', strip=True)
        else:
            text = soup.get_text(separator=' ', strip=True)

        # Basic cleaning
        text = ' '.join(text.split()) # Normalize whitespace
        return text
    except requests.exceptions.RequestException as e:
        print(f"Error fetching {url}: {e}", file=sys.stderr)
        return None
    except Exception as e:
        print(f"Error parsing {url}: {e}", file=sys.stderr)
        return None

def get_tld(url):
    """Extracts the top-level domain from a URL."""
    parsed_url = urlparse(url)
    if parsed_url.netloc:
        parts = parsed_url.netloc.split('.')
        if len(parts) > 1:
            # Simple TLD extraction, might need more robust library for edge cases
            return parts[-2] + '.' + parts[-1]
    return "unknown"

def optimize_for_llm(text, max_chars=4000):
    """Simple optimization: truncate text to max_chars."""
    if text is None:
        return None
    if len(text) > max_chars:
        # Truncate and add an ellipsis
        return text[:max_chars] + "..."
    return text

def main():
    if sys.stdin.isatty():
        print("Usage: cat urls.txt | python extract_and_optimize_knowledge.py > knowledge_data.jsonl", file=sys.stderr)
        sys.exit(1)

    knowledge_items = []
    for line in sys.stdin:
        url = line.strip()
        if not url:
            continue

        print(f"Processing URL: {url}", file=sys.stderr)
        content = fetch_and_parse(url)
        optimized_content = optimize_for_llm(content)

        if optimized_content:
            tld = get_tld(url)
            knowledge_items.append({
                "url": url,
                "tld": tld,
                "content": optimized_content,
                "length": len(optimized_content)
            })
    
    # Output as JSON Lines (one JSON object per line)
    for item in knowledge_items:
        print(json.dumps(item))

if __name__ == "__main__":
    main()
