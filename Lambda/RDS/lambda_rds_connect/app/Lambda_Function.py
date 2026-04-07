import json
import pymysql

RDS_endpoint = "whizdbinstance.cs1yk8i6gu7s.us-east-1.rds.amazonaws.com"
UserName = "admin"
Password = "admin12345"
DatabaseName = "Users"


def lambda_handler(event, context):
    header = []
    row_json = []
    table_json = {}
    connectionString = pymysql.connect(host=RDS_endpoint, user=UserName, password=Password, database=DatabaseName)
    pointer = connectionString.cursor()
    pointer2 = connectionString.cursor()
    pointer.execute('SELECT * FROM tblUsers')
    
    pointer2.execute('DESCRIBE tblUsers')
    #print(pointer2.fetchall())
    
    table_head = pointer2.fetchall()
    for head in table_head:
        header.append(head[0])
    #print(header)
    
    table_rows = pointer.fetchall()
    #print(table_rows)
    
    for r in table_rows:
        row_json.append({header[0] : r[0], header[1] : r[1]})
    table_json = {"student" : row_json}
    for r in table_rows:
        print("---------------------------------")
        print("ID : {}".format(r[0]))
        print("Name : {}".format(r[1]))       
        print("---------------------------------")
    
    return table_json


def InsertData():
    connectionString = pymysql.connect(host=RDS_endpoint, user=UserName, password=Password, database=DatabaseName)
    pointer = connectionString.cursor()
    sql_query = "INSERT INTO tblUsers (ID, Name) VALUES (%s, %s)"
    values = (3, 'Charlie')
    pointer.execute(sql_query, values)
    connectionString.commit()   


if __name__ == "__main__":
    lambda_handler(None, None)