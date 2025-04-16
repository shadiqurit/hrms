import csv
import json

csv_file = 'college_list_all_pages.csv'
json_file = 'college_list_all_pages.json'

data = []

# Read CSV
with open(csv_file, newline='', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        data.append(row)

# Write JSON
with open(json_file, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=4, ensure_ascii=False)

print(f"✅ CSV data converted to JSON and saved as '{json_file}'")
