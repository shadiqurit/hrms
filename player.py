import requests
from bs4 import BeautifulSoup
import pandas as pd
import time

# User-Agent header to mimic a browser
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'
}

# Base URL
base_url = 'https://pesdb.net/efootball/?page={}'

# Store all players
all_players = []

# Loop through all pages
for page in range(1, 561):
    url = base_url.format(page)
    print(f"Scraping Page {page}...")

    response = requests.get(url, headers=headers)
    soup = BeautifulSoup(response.text, 'html.parser')

    # Table rows for players
    rows = soup.select('table#players tbody tr')
    
    if not rows:
        print(f"No data found on page {page}, skipping.")
        continue

    for row in rows:
        cols = row.find_all('td')
        if len(cols) >= 7:
            name = cols[0].get_text(strip=True)
            rating = cols[1].get_text(strip=True)
            position = cols[2].get_text(strip=True)
            team = cols[3].get_text(strip=True)
            age = cols[4].get_text(strip=True)
            height = cols[5].get_text(strip=True)
            weight = cols[6].get_text(strip=True)

            all_players.append({
                'Name': name,
                'Rating': rating,
                'Position': position,
                'Team': team,
                'Age': age,
                'Height': height,
                'Weight': weight
            })

    # Optional: Be polite and don't hammer the server
    time.sleep(1)

# Save to CSV
df = pd.DataFrame(all_players)
df.to_csv('efootball_players_all_pages.csv', index=False, encoding='utf-8-sig')

print("✅ Scraping complete. Data saved to 'efootball_players_all_pages.csv'")
