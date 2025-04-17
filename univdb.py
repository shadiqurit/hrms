import oracledb
import json

# Load JSON file
with open("ugc_universities.json", "r", encoding="utf-8") as f:
    universities = json.load(f)

# Connect to Oracle using the Thin mode (no Oracle Client required)
connection = oracledb.connect(
    user="hr",
    password="hr",
    dsn="localhost:1521/ibnpdb"  # e.g., "localhost:1521/XEPDB1"
)

cursor = connection.cursor()

# Optional: create the table if not exists
cursor.execute("""
    BEGIN
        EXECUTE IMMEDIATE '
            CREATE TABLE ugc_universities (
                sl NUMBER,
                name VARCHAR2(300),
                website VARCHAR2(300)
            )';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -955 THEN -- ORA-00955: name already used by existing object
                RAISE;
            END IF;
    END;
""")

# Insert data
for uni in universities:
    cursor.execute("""
        INSERT INTO ugc_universities (sl, name, website)
        VALUES (:1, :2, :3)
    """, (int(uni["sl"].replace(".", "").strip()), uni["name"], uni["website"]))

connection.commit()
cursor.close()
connection.close()
