import csv
import oracledb

# Setup connection
conn = oracledb.connect(
    user="hr",
    password="hr",
    dsn="localhost/ibnpdb"  # ← replace with your local service name if different
)

try:
    cursor = conn.cursor()

    with open("all_unique_colleges.csv", newline='', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)

        for row in reader:
            cursor.execute("""
                INSERT INTO nu_colleges (college_code, college_name, email, phone, address)
                VALUES (:1, :2, :3, :4, :5)
            """, (
                row['College Code'],
                row['College Name'],
                row['Email'],
                row['Phone'],
                row['Address']
            ))

    conn.commit()
    print("✅ Upload complete.")

finally:
    conn.close()
