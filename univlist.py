import requests
from bs4 import BeautifulSoup
import json

url = "http://www.ugc-universities.gov.bd/international-universities"
response = requests.get(url)
response.encoding = 'utf-8'

soup = BeautifulSoup(response.text, "html.parser")
table = soup.find("table")

universities = []

for row in table.find_all("tr")[1:]:  # Skip the header row
    cols = row.find_all("td")
    if len(cols) >= 3:
        sl = cols[0].get_text(strip=True)
        name = cols[1].get_text(strip=True)

        # Try to get website link or fallback to text
        website_link = cols[2].find("a")
        if website_link and website_link.has_attr("href"):
            website = website_link["href"]
        else:
            website = cols[2].get_text(strip=True) or None

        universities.append({
            "sl": sl,
            "name": name,
            "website": website
        })

json_output = json.dumps(universities, indent=2, ensure_ascii=False)

# Save to file
with open("ugc_universities.json", "w", encoding="utf-8") as f:
    f.write(json_output)

print(json_output)
