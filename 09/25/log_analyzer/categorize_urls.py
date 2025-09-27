import sys
import re

def categorize_url(url):
    if "nixos.org" in url or "nixpkgs" in url or "flake.nix" in url:
        return "Nix/NixOS"
    elif "github.com" in url:
        # Further refine GitHub URLs
        if "/topics/" in url:
            return "GitHub Topic"
        elif re.search(r"github\.com/[^/]+/[^/]+\.git", url):
            return "GitHub Repository (Git)"
        else:
            return "GitHub (General)"
    elif "files.pythonhosted.org" in url or "pypi.python.org" in url:
        return "Python Package"
    elif "crates.io" in url:
        return "Rust Crate"
    else:
        return "Other/Uncategorized"

def main():
    categorized_urls = {}
    for line in sys.stdin:
        if not line.strip() or "---" in line or "URL Histogram" in line:
            continue
        
        parts = line.rsplit(': ', 1)
        if len(parts) == 2:
            url = parts[0].strip().replace('\n', '').replace('\"', '').replace("'", '')
            count = int(parts[1])
            category = categorize_url(url)
            
            if category not in categorized_urls:
                categorized_urls[category] = []
            categorized_urls[category].append({"url": url, "count": count})

    for category, urls in categorized_urls.items():
        print(f"\nCategory: {category}")
        print("--------------------")
        for item in urls:
            print(f"  Count: {item['count']}, URL: {item['url']}")

if __name__ == "__main__":
    main()