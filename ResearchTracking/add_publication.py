#!/usr/bin/env python3
"""
Publication Management Script for MirrorHR Research Tracking

This script helps manage research publication entries in the publications.json file.
It can add new publications, generate IDs, and validate entries.
"""

import json
import uuid
import datetime
import sys
import re
import os
from typing import Dict, List, Any, Optional

# File paths
PUBLICATIONS_FILE = os.path.join(os.path.dirname(__file__), 'publications.json')
TEMPLATE_FILE = os.path.join(os.path.dirname(__file__), 'PUBLICATION_TEMPLATE.md')

def load_publications() -> Dict[str, Any]:
    """Load existing publications database."""
    try:
        with open(PUBLICATIONS_FILE, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Error: {PUBLICATIONS_FILE} not found")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: {PUBLICATIONS_FILE} contains invalid JSON")
        sys.exit(1)

def save_publications(data: Dict[str, Any]) -> None:
    """Save publications database with pretty formatting."""
    with open(PUBLICATIONS_FILE, 'w') as f:
        json.dump(data, f, indent=2)
    print(f"Successfully saved to {PUBLICATIONS_FILE}")

def generate_publication_id() -> str:
    """Generate a new publication ID in the format MHR-PUB-YYYY-XXX."""
    current_year = datetime.datetime.now().year
    publications = load_publications()
    
    # Find the highest ID number for the current year
    max_id = 0
    pattern = f"MHR-PUB-{current_year}-(\\d+)"
    
    for pub in publications.get('publications', []):
        if match := re.match(pattern, pub.get('id', '')):
            id_num = int(match.group(1))
            max_id = max(max_id, id_num)
    
    # Generate new ID with incremented number
    return f"MHR-PUB-{current_year}-{max_id + 1:03d}"

def add_publication(pub_data: Dict[str, Any]) -> None:
    """Add a new publication to the database."""
    publications = load_publications()
    
    # Generate ID if not provided
    if 'id' not in pub_data:
        pub_data['id'] = generate_publication_id()
    
    # Add submission date if not provided
    if 'submission_date' not in pub_data:
        pub_data['submission_date'] = datetime.datetime.now().strftime('%Y-%m-%d')
    
    # Add the new publication
    publications['publications'].append(pub_data)
    
    # Save the updated data
    save_publications(publications)
    print(f"Added publication: {pub_data['title']} (ID: {pub_data['id']})")

def validate_publication(pub_data: Dict[str, Any]) -> List[str]:
    """Validate a publication entry against the schema."""
    publications = load_publications()
    schema = publications.get('schema', {})
    required_fields = schema.get('properties', {}).get('publications', {}).get('items', {}).get('required', [])
    
    errors = []
    
    # Check required fields
    for field in required_fields:
        if field not in pub_data:
            errors.append(f"Missing required field: {field}")
    
    # Validate email format
    if 'contact_email' in pub_data:
        email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(email_pattern, pub_data['contact_email']):
            errors.append("Invalid email format")
    
    # Validate date formats
    date_fields = ['publication_date', 'submission_date']
    date_pattern = r'^\d{4}-\d{2}-\d{2}$'
    for field in date_fields:
        if field in pub_data and not re.match(date_pattern, pub_data[field]):
            errors.append(f"Invalid date format for {field} (should be YYYY-MM-DD)")
    
    return errors

def interactive_add() -> None:
    """Add a publication interactively."""
    pub_data = {}
    
    print("=== Add New Research Publication ===")
    pub_data['title'] = input("Publication title: ")
    
    # Authors (list)
    authors = []
    print("Enter authors (one per line, blank line to finish):")
    while True:
        author = input("> ")
        if not author:
            break
        authors.append(author)
    pub_data['authors'] = authors
    
    pub_data['publication_date'] = input("Publication date (YYYY-MM-DD): ")
    pub_data['venue'] = input("Journal/Conference name: ")
    pub_data['doi'] = input("DOI (optional, press Enter to skip): ") or None
    pub_data['url'] = input("URL (optional, press Enter to skip): ") or None
    
    print("Enter abstract (press Enter on empty line to finish):")
    abstract_lines = []
    while True:
        line = input()
        if not line and abstract_lines:
            break
        abstract_lines.append(line)
    pub_data['abstract'] = "\n".join(abstract_lines)
    
    print("Enter data usage description (how MirrorHR data was used):")
    usage_lines = []
    while True:
        line = input()
        if not line and usage_lines:
            break
        usage_lines.append(line)
    pub_data['data_usage'] = "\n".join(usage_lines)
    
    pub_data['contact_email'] = input("Contact email: ")
    
    # Tags (list)
    tags = []
    print("Enter tags (one per line, blank line to finish):")
    while True:
        tag = input("> ")
        if not tag:
            break
        tags.append(tag.lower())
    pub_data['tags'] = tags
    
    # Validate
    errors = validate_publication(pub_data)
    if errors:
        print("\nValidation errors:")
        for error in errors:
            print(f"- {error}")
        if input("\nAdd anyway? (y/n): ").lower() != 'y':
            print("Publication not added.")
            return
    
    # Add the publication
    add_publication(pub_data)

def print_usage() -> None:
    """Print usage information."""
    print(f"""
Usage: {sys.argv[0]} COMMAND [OPTIONS]

Commands:
  add           Add a new publication interactively
  generate-id   Generate a new publication ID
  validate      Validate the publications database
  help          Show this help message

Examples:
  {sys.argv[0]} add
  {sys.argv[0]} generate-id
  {sys.argv[0]} validate
""")

def main() -> None:
    """Main entry point."""
    if len(sys.argv) < 2 or sys.argv[1] == 'help':
        print_usage()
        return
    
    command = sys.argv[1].lower()
    
    if command == 'add':
        interactive_add()
    elif command == 'generate-id':
        print(generate_publication_id())
    elif command == 'validate':
        publications = load_publications()
        all_valid = True
        for pub in publications.get('publications', []):
            errors = validate_publication(pub)
            if errors:
                print(f"\nValidation errors for {pub.get('id', 'Unknown ID')}:")
                for error in errors:
                    print(f"- {error}")
                all_valid = False
        
        if all_valid:
            print("All publications passed validation.")
    else:
        print(f"Unknown command: {command}")
        print_usage()

if __name__ == "__main__":
    main() 