import csv
import oracledb

conn = oracledb.connect(
    user="hr",
    password="hr",
    dsn="localhost/ibnpdb"
)

try:
    cursor = conn.cursor()

    # Start ID counter
    id_counter = 1

    with open("mad.csv", newline='', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)

        for row in reader:
            cursor.execute("""
                INSERT INTO madrasah (
                    id, division, district, upazila_thana, eiin,
                    name, edu_level, mobile, email, management,
                    mpo, stud_type
                )
                VALUES (
                    :1, :2, :3, :4, :5,
                    :6, :7, :8, :9, :10,
                    :11, :12
                )
            """, (
                id_counter,
                row['DIVISION'],
                row['DISTRICT'],
                row['UPAZILA_THANA'],
                row['EIIN'],
                row['NAME'],
                row['EDU_LEVEL'],
                row['MOBILE'],
                row['EMAIL'],
                row['MANAGEMENT'],
                row['MPO'],
                row['STUD_TYPE']
            ))
            id_counter += 1

    conn.commit()
    print("✅ Upload complete.")

finally:
    conn.close()
