import requests
from bs4 import BeautifulSoup
import csv

college_dict = {}
base_url = "http://103.113.200.68/nu-app/college/paging/"

# Start from 25 to 2400 (inclusive), step by 25
for offset in range(0, 2401, 25):
    url = f"{base_url}{offset}"
    print(f"Scraping: {url}")
    
    response = requests.get(url)
    if response.status_code != 200:
        print(f"⚠️ Failed to load offset {offset}")
        continue

    soup = BeautifulSoup(response.text, "html.parser")
    rows = soup.find_all("tr")

    for row in rows[1:]:  # Skip header
        cols = row.find_all("td")
        if len(cols) >= 5:
            college_code = cols[0].get_text(strip=True)
            college_name = cols[1].get_text(strip=True)
            email = cols[2].get_text(strip=True)
            phone = cols[3].get_text(strip=True)
            address = cols[4].get_text(strip=True)

            # Store only unique college codes
            college_dict[college_code] = (
                college_name, email, phone, address
            )

# Save to CSV
with open("all_unique_colleges.csv", "w", newline="", encoding="utf-8") as file:
    writer = csv.writer(file)
    writer.writerow(["College Code", "College Name", "Email", "Phone", "Address"])
    for code, data in college_dict.items():
        writer.writerow([code] + list(data))

print(f"✅ Done! Total unique colleges saved: {len(college_dict)}")
