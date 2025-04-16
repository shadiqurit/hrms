import requests
from bs4 import BeautifulSoup
import csv

# CSV file setup
with open('college_list_all_pages.csv', 'w', newline='', encoding='utf-8') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(['College Code', 'College Name', 'Email', 'Phone', 'Address'])

    # Loop through pages 1 to 97
    for page in range(1, 98):  # 98 because range is exclusive on the upper end
        url = f"http://103.113.200.68/nu-app/college/?page={page}"
        print(f"Scraping Page {page}...")

        response = requests.get(url)

        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')
            rows = soup.find_all('tr')

            for row in rows[1:]:  # Skip the header row on each page
                cells = row.find_all('td')
                if len(cells) >= 5:
                    college_code = cells[0].get_text(strip=True)
                    college_name = cells[1].get_text(strip=True)
                    email = cells[2].get_text(strip=True)
                    phone = cells[3].get_text(strip=True)
                    address = cells[4].get_text(strip=True)

                    writer.writerow([college_code, college_name, email, phone, address])
        else:
            print(f"Failed to load page {page}. Status code: {response.status_code}")

print("✅ All data has been saved to 'college_list_all_pages.csv'")
