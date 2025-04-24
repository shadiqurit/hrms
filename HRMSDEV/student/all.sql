-- ORACLE APEX IMPLEMENTATION FOR SCHOOL AND COLLEGE MANAGEMENT SYSTEM

-- TABLE CREATION SCRIPTS ADAPTED FOR ORACLE

-- Users (Base table for authentication)
CREATE TABLE Users (
    UserID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Username VARCHAR2(50) UNIQUE NOT NULL,
    PasswordHash VARCHAR2(255) NOT NULL,
    Email VARCHAR2(100) UNIQUE NOT NULL,
    UserType VARCHAR2(20) CHECK (UserType IN ('Admin', 'Teacher', 'Student', 'Guardian', 'Librarian', 'Staff')) NOT NULL,
    IsActive NUMBER(1) DEFAULT 1,
    LastLogin TIMESTAMP,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Institutions
CREATE TABLE Institutions (
    InstitutionID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Name VARCHAR2(100) NOT NULL,
    Address CLOB NOT NULL,
    Phone VARCHAR2(20),
    Email VARCHAR2(100),
    Website VARCHAR2(100),
    FoundedYear NUMBER,
    LogoURL VARCHAR2(255),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Departments
CREATE TABLE Departments (
    DepartmentID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    InstitutionID NUMBER NOT NULL,
    Name VARCHAR2(100) NOT NULL,
    Description CLOB,
    HeadID NUMBER, -- References Teachers.TeacherID - will add constraint later
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Dept_Institution FOREIGN KEY (InstitutionID) REFERENCES Institutions(InstitutionID)
);

-- Academic Years
CREATE TABLE AcademicYears (
    AcademicYearID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    InstitutionID NUMBER NOT NULL,
    Name VARCHAR2(50) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    IsActive NUMBER(1) DEFAULT 0,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_AcadYear_Institution FOREIGN KEY (InstitutionID) REFERENCES Institutions(InstitutionID)
);

-- Terms/Semesters
CREATE TABLE Terms (
    TermID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    AcademicYearID NUMBER NOT NULL,
    Name VARCHAR2(50) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    IsActive NUMBER(1) DEFAULT 0,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Term_AcadYear FOREIGN KEY (AcademicYearID) REFERENCES AcademicYears(AcademicYearID)
);

-- Students
CREATE TABLE Students (
    StudentID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    UserID NUMBER NOT NULL,
    StudentNumber VARCHAR2(20) UNIQUE NOT NULL,
    FirstName VARCHAR2(50) NOT NULL,
    MiddleName VARCHAR2(50),
    LastName VARCHAR2(50) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender VARCHAR2(10) CHECK (Gender IN ('Male', 'Female', 'Other')) NOT NULL,
    Address CLOB,
    Phone VARCHAR2(20),
    Email VARCHAR2(100),
    EnrollmentDate DATE NOT NULL,
    GraduationDate DATE,
    Status VARCHAR2(20) DEFAULT 'Active' CHECK (Status IN ('Active', 'Graduated', 'Withdrawn', 'Suspended', 'Alumni')),
    Photo VARCHAR2(255),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Student_User FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- PL/SQL TRIGGERS FOR UPDATING TIMESTAMPS

-- Create a trigger to update the UpdatedAt timestamp for Users
CREATE OR REPLACE TRIGGER users_update_trigger
BEFORE UPDATE ON Users
FOR EACH ROW
BEGIN
    :NEW.UpdatedAt := CURRENT_TIMESTAMP;
END;
/

-- Create similar triggers for all other tables
CREATE OR REPLACE TRIGGER institutions_update_trigger
BEFORE UPDATE ON Institutions
FOR EACH ROW
BEGIN
    :NEW.UpdatedAt := CURRENT_TIMESTAMP;
END;
/

-- APEX APPLICATION SETUP - MAIN PROCEDURES

-- Generate Student ID Numbers
CREATE OR REPLACE PROCEDURE gen_student_number(
    p_academic_year IN VARCHAR2,
    p_program_code IN VARCHAR2,
    p_student_id OUT VARCHAR2
) IS
    v_counter NUMBER;
    v_year_code VARCHAR2(4);
    v_program_code VARCHAR2(3);
BEGIN
    -- Get the year code (last 2 digits)
    v_year_code := SUBSTR(p_academic_year, 3, 2);
    
    -- Program code (first 3 letters)
    v_program_code := UPPER(SUBSTR(p_program_code, 1, 3));
    
    -- Get the next counter
    SELECT NVL(MAX(TO_NUMBER(SUBSTR(StudentNumber, 8))), 0) + 1
    INTO v_counter
    FROM Students
    WHERE SUBSTR(StudentNumber, 1, 7) = v_year_code || v_program_code || '-';
    
    -- Generate the student ID
    p_student_id := v_year_code || v_program_code || '-' || LPAD(v_counter, 4, '0');
END;
/

-- APEX PAGE DEFINITIONS - LOGIN PAGE

-- Create package for custom authentication
CREATE OR REPLACE PACKAGE user_auth AS
    FUNCTION validate_credentials(p_username IN VARCHAR2, p_password IN VARCHAR2) RETURN BOOLEAN;
    PROCEDURE create_user_session(p_user_id IN NUMBER, p_username IN VARCHAR2, p_user_type IN VARCHAR2);
    PROCEDURE logout_user;
END user_auth;
/

CREATE OR REPLACE PACKAGE BODY user_auth AS
    FUNCTION validate_credentials(p_username IN VARCHAR2, p_password IN VARCHAR2) RETURN BOOLEAN IS
        v_stored_hash VARCHAR2(255);
        v_user_id NUMBER;
        v_is_active NUMBER;
    BEGIN
        -- Get the stored password hash and check if user is active
        SELECT UserID, PasswordHash, IsActive
        INTO v_user_id, v_stored_hash, v_is_active
        FROM Users
        WHERE LOWER(Username) = LOWER(p_username);
        
        -- Verify active status
        IF v_is_active = 0 THEN
            RETURN FALSE;
        END IF;
        
        -- For APEX demonstration, we'll use a simple check
        -- In a real implementation, use proper password hashing like DBMS_CRYPTO
        IF v_stored_hash = p_password THEN
            -- Update last login time
            UPDATE Users SET LastLogin = CURRENT_TIMESTAMP WHERE UserID = v_user_id;
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END validate_credentials;
    
    PROCEDURE create_user_session(p_user_id IN NUMBER, p_username IN VARCHAR2, p_user_type IN VARCHAR2) IS
    BEGIN
        -- Set APEX session variables
        APEX_UTIL.SET_SESSION_STATE('USER_ID', p_user_id);
        APEX_UTIL.SET_SESSION_STATE('USERNAME', p_username);
        APEX_UTIL.SET_SESSION_STATE('USER_TYPE', p_user_type);
    END create_user_session;
    
    PROCEDURE logout_user IS
    BEGIN
        -- Clear session variables
        APEX_UTIL.CLEAR_SESSION_STATE('USER_ID');
        APEX_UTIL.CLEAR_SESSION_STATE('USERNAME');
        APEX_UTIL.CLEAR_SESSION_STATE('USER_TYPE');
    END logout_user;
END user_auth;
/

-- APEX DASHBOARD PAGE SETUP

-- Create views for dashboard statistics
CREATE OR REPLACE VIEW dashboard_student_stats AS
SELECT 
    COUNT(*) AS total_students,
    COUNT(CASE WHEN Status = 'Active' THEN 1 END) AS active_students,
    COUNT(CASE WHEN TO_CHAR(EnrollmentDate, 'YYYY-MM') = TO_CHAR(SYSDATE, 'YYYY-MM') THEN 1 END) AS new_students_this_month
FROM Students;

CREATE OR REPLACE VIEW dashboard_attendance_stats AS
SELECT 
    c.Name AS class_name,
    s.SubjectID,
    sub.Name AS subject_name,
    COUNT(sa.AttendanceID) AS total_attendance_records,
    SUM(CASE WHEN sa.Status = 'Present' THEN 1 ELSE 0 END) AS present_count,
    ROUND(SUM(CASE WHEN sa.Status = 'Present' THEN 1 ELSE 0 END) / COUNT(sa.AttendanceID) * 100, 2) AS attendance_percentage
FROM StudentAttendance sa
JOIN ClassSubjects cs ON sa.ClassSubjectID = cs.ClassSubjectID
JOIN Classes c ON cs.ClassID = c.ClassID
JOIN Subjects sub ON cs.SubjectID = sub.SubjectID
JOIN Students s ON sa.StudentID = s.StudentID
WHERE sa.Date BETWEEN SYSDATE - 30 AND SYSDATE
GROUP BY c.Name, s.SubjectID, sub.Name;

-- DYNAMIC ACTION FOR STUDENT REGISTRATION

-- Create procedure for student registration process
CREATE OR REPLACE PROCEDURE register_new_student(
    p_first_name IN VARCHAR2,
    p_middle_name IN VARCHAR2,
    p_last_name IN VARCHAR2,
    p_email IN VARCHAR2,
    p_dob IN DATE,
    p_gender IN VARCHAR2,
    p_address IN CLOB,
    p_phone IN VARCHAR2,
    p_program_id IN NUMBER,
    p_academic_year_id IN NUMBER,
    p_class_id IN NUMBER,
    p_guardian_name IN VARCHAR2,
    p_guardian_phone IN VARCHAR2,
    p_guardian_relation IN VARCHAR2,
    p_result OUT VARCHAR2,
    p_student_id OUT NUMBER
) 
AS
    v_user_id NUMBER;
    v_guardian_id NUMBER;
    v_student_number VARCHAR2(20);
    v_username VARCHAR2(50);
    v_password VARCHAR2(255);
    v_program_code VARCHAR2(10);
    v_academic_year VARCHAR2(10);
BEGIN
    -- Get program code and academic year for student number generation
    SELECT p.Code, ay.Name
    INTO v_program_code, v_academic_year
    FROM Programs p, AcademicYears ay
    WHERE p.ProgramID = p_program_id AND ay.AcademicYearID = p_academic_year_id;
    
    -- Generate student number
    gen_student_number(v_academic_year, v_program_code, v_student_number);
    
    -- Create username from first letter of first name and last name
    v_username := LOWER(SUBSTR(p_first_name, 1, 1) || p_last_name);
    
    -- Generate a random password (in real system, use secure method)
    v_password := DBMS_RANDOM.STRING('X', 10);
    
    -- Create user account
    INSERT INTO Users (Username, PasswordHash, Email, UserType, IsActive)
    VALUES (v_username, v_password, p_email, 'Student', 1)
    RETURNING UserID INTO v_user_id;
    
    -- Create student record
    INSERT INTO Students (
        UserID, StudentNumber, FirstName, MiddleName, LastName, 
        DateOfBirth, Gender, Address, Phone, Email, EnrollmentDate, Status
    ) VALUES (
        v_user_id, v_student_number, p_first_name, p_middle_name, p_last_name,
        p_dob, p_gender, p_address, p_phone, p_email, SYSDATE, 'Active'
    ) RETURNING StudentID INTO p_student_id;
    
    -- Check if guardian exists by phone number
    BEGIN
        SELECT GuardianID INTO v_guardian_id
        FROM Guardians
        WHERE Phone = p_guardian_phone;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Create new guardian
            INSERT INTO Guardians (FirstName, Phone, Relationship)
            VALUES (p_guardian_name, p_guardian_phone, p_guardian_relation)
            RETURNING GuardianID INTO v_guardian_id;
    END;
    
    -- Link student with guardian
    INSERT INTO StudentGuardians (StudentID, GuardianID, IsPrimary)
    VALUES (p_student_id, v_guardian_id, 1);
    
    -- Enroll student in the specified class
    INSERT INTO StudentClassEnrollments (StudentID, ClassID, EnrollmentDate, Status)
    VALUES (p_student_id, p_class_id, SYSDATE, 'Active');
    
    -- Return success message
    p_result := 'Student ' || p_first_name || ' ' || p_last_name || ' successfully registered with ID: ' || v_student_number;
    
    -- Log activity
    INSERT INTO ActivityLogs (UserID, Activity, IPAddress)
    VALUES (
        APEX_UTIL.GET_SESSION_STATE('USER_ID'),
        'Registered new student: ' || v_student_number,
        OWA_UTIL.GET_CGI_ENV('REMOTE_ADDR')
    );
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_result := 'Error: ' || SQLERRM;
END register_new_student;
/

-- ATTENDANCE MANAGEMENT PROCEDURES

-- Create procedure to mark student attendance
CREATE OR REPLACE PROCEDURE mark_student_attendance(
    p_class_subject_id IN NUMBER,
    p_date IN DATE,
    p_recorded_by IN NUMBER
) IS
BEGIN
    -- Insert attendance records for all students in the class
    INSERT INTO StudentAttendance (StudentID, ClassSubjectID, Date, Status, RecordedBy)
    SELECT sce.StudentID, p_class_subject_id, p_date, 'Absent', p_recorded_by
    FROM StudentClassEnrollments sce
    JOIN ClassSubjects cs ON cs.ClassID = sce.ClassID
    WHERE cs.ClassSubjectID = p_class_subject_id
    AND sce.Status = 'Active'
    AND NOT EXISTS (
        SELECT 1 FROM StudentAttendance sa
        WHERE sa.StudentID = sce.StudentID
        AND sa.ClassSubjectID = p_class_subject_id
        AND sa.Date = p_date
    );
    
    COMMIT;
END mark_student_attendance;
/

-- Create procedure to update student attendance
CREATE OR REPLACE PROCEDURE update_student_attendance(
    p_student_id IN NUMBER,
    p_class_subject_id IN NUMBER,
    p_date IN DATE,
    p_status IN VARCHAR2,
    p_remarks IN VARCHAR2,
    p_recorded_by IN NUMBER
) IS
BEGIN
    UPDATE StudentAttendance
    SET Status = p_status,
        Remarks = p_remarks,
        RecordedBy = p_recorded_by,
        UpdatedAt = CURRENT_TIMESTAMP
    WHERE StudentID = p_student_id
    AND ClassSubjectID = p_class_subject_id
    AND Date = p_date;
    
    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO StudentAttendance (StudentID, ClassSubjectID, Date, Status, Remarks, RecordedBy)
        VALUES (p_student_id, p_class_subject_id, p_date, p_status, p_remarks, p_recorded_by);
    END IF;
    
    COMMIT;
END update_student_attendance;
/

-- REPORT CARD GENERATION

CREATE OR REPLACE PROCEDURE generate_report_cards(
    p_class_id IN NUMBER,
    p_exam_id IN NUMBER
) IS
    v_report_card_id NUMBER;
    v_total_marks NUMBER;
    v_average_percentage NUMBER;
    v_cgpa NUMBER;
    v_rank NUMBER;
BEGIN
    -- For each student in the class
    FOR student_rec IN (
        SELECT s.StudentID, s.FirstName, s.LastName
        FROM Students s
        JOIN StudentClassEnrollments sce ON s.StudentID = sce.StudentID
        WHERE sce.ClassID = p_class_id AND sce.Status = 'Active'
    )
    LOOP
        -- Calculate total marks and average for the student
        SELECT 
            NVL(SUM(ser.MarksObtained), 0) AS total_marks,
            NVL(AVG(ser.MarksObtained / se.TotalMarks * 100), 0) AS avg_percentage,
            NVL(AVG(gs.GradePoint), 0) AS avg_gpa
        INTO v_total_marks, v_average_percentage, v_cgpa
        FROM StudentExamResults ser
        JOIN SubjectExams se ON ser.SubjectExamID = se.SubjectExamID
        JOIN GradingScales gs ON ser.GradeID = gs.GradeID
        WHERE ser.StudentID = student_rec.StudentID
        AND se.ExamID = p_exam_id;
        
        -- Check if report card already exists
        BEGIN
            SELECT ReportCardID 
            INTO v_report_card_id
            FROM ReportCards
            WHERE StudentID = student_rec.StudentID
            AND ClassID = p_class_id
            AND ExamID = p_exam_id;
            
            -- Update existing report card
            UPDATE ReportCards
            SET TotalMarks = v_total_marks,
                AveragePercentage = v_average_percentage,
                CGPA = v_cgpa,
                GeneratedDate = SYSDATE,
                Status = 'Draft',
                UpdatedAt = CURRENT_TIMESTAMP
            WHERE ReportCardID = v_report_card_id;
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- Create new report card
                INSERT INTO ReportCards (
                    StudentID, ClassID, ExamID, TotalMarks, 
                    AveragePercentage, CGPA, GeneratedDate, Status
                ) VALUES (
                    student_rec.StudentID, p_class_id, p_exam_id, v_total_marks,
                    v_average_percentage, v_cgpa, SYSDATE, 'Draft'
                );
        END;
    END LOOP;
    
    -- Calculate and update ranks
    UPDATE ReportCards rc1
    SET Rank = (
        SELECT COUNT(*) + 1
        FROM ReportCards rc2
        WHERE rc2.ClassID = rc1.ClassID
        AND rc2.ExamID = rc1.ExamID
        AND rc2.AveragePercentage > rc1.AveragePercentage
    )
    WHERE ClassID = p_class_id
    AND ExamID = p_exam_id;
    
    COMMIT;
END generate_report_cards;
/

-- FEE MANAGEMENT

-- Create procedure to generate student fees
CREATE OR REPLACE PROCEDURE generate_student_fees(
    p_academic_year_id IN NUMBER,
    p_program_id IN NUMBER
) IS
BEGIN
    -- For each fee structure in the academic year and program
    FOR fee_rec IN (
        SELECT fs.FeeStructureID, fs.Amount, fs.DueDate
        FROM FeeStructures fs
        WHERE fs.AcademicYearID = p_academic_year_id
        AND fs.ProgramID = p_program_id
    )
    LOOP
        -- For each student in the program
        FOR student_rec IN (
            SELECT s.StudentID
            FROM Students s
            JOIN StudentClassEnrollments sce ON s.StudentID = sce.StudentID
            JOIN Classes c ON sce.ClassID = c.ClassID
            WHERE c.ProgramID = p_program_id
            AND c.AcademicYearID = p_academic_year_id
            AND sce.Status = 'Active'
            AND s.Status = 'Active'
        )
        LOOP
            -- Check if fee already exists
            IF NOT EXISTS (
                SELECT 1 FROM StudentFees sf
                WHERE sf.StudentID = student_rec.StudentID
                AND sf.FeeStructureID = fee_rec.FeeStructureID
            ) THEN
                -- Create student fee
                INSERT INTO StudentFees (
                    StudentID, FeeStructureID, AmountDue, 
                    NetAmount, DueDate, Status
                ) VALUES (
                    student_rec.StudentID, fee_rec.FeeStructureID, fee_rec.Amount,
                    fee_rec.Amount, fee_rec.DueDate, 'Unpaid'
                );
            END IF;
        END LOOP;
    END LOOP;
    
    COMMIT;
END generate_student_fees;
/

-- Create procedure to record fee payment
CREATE OR REPLACE PROCEDURE record_fee_payment(
    p_student_fee_id IN NUMBER,
    p_amount IN NUMBER,
    p_payment_method IN VARCHAR2,
    p_transaction_ref IN VARCHAR2,
    p_received_by IN NUMBER,
    p_remarks IN VARCHAR2
) IS
    v_amount_due NUMBER;
    v_net_amount NUMBER;
    v_paid_amount NUMBER;
    v_new_status VARCHAR2(20);
BEGIN
    -- Get current fee details
    SELECT SF.AmountDue, SF.NetAmount, NVL(SUM(FP.Amount), 0) AS paid_amount
    INTO v_amount_due, v_net_amount, v_paid_amount
    FROM StudentFees SF
    LEFT JOIN FeePayments FP ON SF.StudentFeeID = FP.StudentFeeID
    WHERE SF.StudentFeeID = p_student_fee_id
    GROUP BY SF.AmountDue, SF.NetAmount;
    
    -- Insert payment record
    INSERT INTO FeePayments (
        StudentFeeID, Amount, PaymentDate, PaymentMethod, 
        TransactionReference, ReceivedBy, Remarks
    ) VALUES (
        p_student_fee_id, p_amount, SYSDATE, p_payment_method,
        p_transaction_ref, p_received_by, p_remarks
    );
    
    -- Update fee status
    v_paid_amount := v_paid_amount + p_amount;
    
    IF v_paid_amount >= v_net_amount THEN
        v_new_status := 'Paid';
    ELSIF v_paid_amount > 0 THEN
        v_new_status := 'Partially Paid';
    ELSE
        v_new_status := 'Unpaid';
    END IF;
    
    UPDATE StudentFees
    SET Status = v_new_status,
        UpdatedAt = CURRENT_TIMESTAMP
    WHERE StudentFeeID = p_student_fee_id;
    
    COMMIT;
END record_fee_payment;
/

-- LIBRARY MANAGEMENT

-- Create procedure to issue a book
CREATE OR REPLACE PROCEDURE issue_book(
    p_member_id IN NUMBER,
    p_book_id IN NUMBER,
    p_issued_by IN NUMBER,
    p_result OUT VARCHAR2
) IS
    v_max_books NUMBER;
    v_books_issued NUMBER;
    v_member_status VARCHAR2(20);
    v_copy_id NUMBER;
BEGIN
    -- Check if member is active
    SELECT MaxBooks, Status
    INTO v_max_books, v_member_status
    FROM LibraryMembers
    WHERE MemberID = p_member_id;
    
    IF v_member_status != 'Active' THEN
        p_result := 'Cannot issue book: Member is not active.';
        RETURN;
    END IF;
    
    -- Check if member has reached maximum books limit
    SELECT COUNT(*)
    INTO v_books_issued
    FROM BookIssues
    WHERE MemberID = p_member_id
    AND Status IN ('Issued', 'Overdue');
    
    IF v_books_issued >= v_max_books THEN
        p_result := 'Cannot issue book: Member has already issued maximum allowed books.';
        RETURN;
    END IF;
    
    -- Find an available copy of the book
    BEGIN
        SELECT CopyID
        INTO v_copy_id
        FROM BookCopies
        WHERE BookID = p_book_id
        AND Status = 'Available'
        AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_result := 'Cannot issue book: No available copies.';
            RETURN;
    END;
    
    -- Update book copy status
    UPDATE BookCopies
    SET Status = 'Issued',
        UpdatedAt = CURRENT_TIMESTAMP
    WHERE CopyID = v_copy_id;
    
    -- Create book issue record
    INSERT INTO BookIssues (
        MemberID, CopyID, IssueDate, DueDate, 
        IssuedBy, Status
    ) VALUES (
        p_member_id, v_copy_id, SYSDATE, SYSDATE + 14, -- 14 days due date
        p_issued_by, 'Issued'
    );
    
    -- Update book availability counter
    UPDATE Books
    SET AvailableCopies = AvailableCopies - 1,
        UpdatedAt = CURRENT_TIMESTAMP
    WHERE BookID = p_book_id;
    
    COMMIT;
    p_result := 'Book issued successfully.';
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_result := 'Error: ' || SQLERRM;
END issue_book;
/

-- Create procedure to return a book
CREATE OR REPLACE PROCEDURE return_book(
    p_issue_id IN NUMBER,
    p_returned_to IN NUMBER,
    p_result OUT VARCHAR2
) IS
    v_copy_id NUMBER;
    v_book_id NUMBER;
    v_due_date DATE;
    v_fine_amount NUMBER := 0;
    v_fine_status VARCHAR2(20) := 'Not Applicable';
BEGIN
    -- Get issue details
    SELECT bi.CopyID, bc.BookID, bi.DueDate
    INTO v_copy_id, v_book_id, v_due_date
    FROM BookIssues bi
    JOIN BookCopies bc ON bi.CopyID = bc.CopyID
    WHERE bi.IssueID = p_issue_id
    AND bi.Status IN ('Issued', 'Overdue');
    
    -- Calculate fine if any
    IF SYSDATE > v_due_date THEN
        -- Fine calculation: $1 per day
        v_fine_amount := (SYSDATE - v_due_date) * 1;
        v_fine_status := 'Pending';
    END IF;
    
    -- Update book issue record
    UPDATE BookIssues
    SET ReturnDate = SYSDATE,
        ReturnedTo = p_returned_to,
        FineAmount = v_fine_amount,
        FineStatus = v_fine_status,
        Status = 'Returned',
        UpdatedAt = CURRENT_TIMESTAMP
    WHERE IssueID = p_issue_id;
    
    -- Update book copy status
    UPDATE BookCopies
    SET Status = 'Available',
        UpdatedAt = CURRENT_TIMESTAMP
    WHERE CopyID = v_copy_id;
    
    -- Update book availability counter
    UPDATE Books
    SET AvailableCopies = AvailableCopies + 1,
        UpdatedAt = CURRENT_TIMESTAMP
    WHERE BookID = v_book_id;
    
    COMMIT;
    
    IF v_fine_amount > 0 THEN
        p_result := 'Book returned successfully. Fine amount: $' || v_fine_amount;
    ELSE
        p_result := 'Book returned successfully.';
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_result := 'Error: Issue record not found or book already returned.';
    WHEN OTHERS THEN
        ROLLBACK;
        p_result := 'Error: ' || SQLERRM;
END return_book;
/

-- ID CARD MANAGEMENT

-- Create procedure to generate ID card
CREATE OR REPLACE PROCEDURE generate_id_card(
    p_user_id IN NUMBER,
    p_issued_by IN NUMBER,
    p_expiry_years IN NUMBER DEFAULT 4,
    p_result OUT VARCHAR2
) IS
    v_card_number VARCHAR2(50);
    v_user_type VARCHAR2(20);
    v_ref_id VARCHAR2(20);
BEGIN
    -- Get user type
    SELECT UserType INTO v_user_type
    FROM Users
    WHERE UserID = p_user_id;
    
    -- Get reference ID based on user type
    IF v_user_type = 'Student' THEN
        SELECT StudentNumber INTO v_ref_id
        FROM Students
        WHERE UserID = p_user_id;
    ELSIF v_user_type = 'Teacher' THEN
        SELECT EmployeeID INTO v_ref_id
        FROM Teachers
        WHERE UserID = p_user_id;
    ELSE
        v_ref_id := 'STF' || LPAD(p_user_id, 6, '0');
    END IF;
    
    -- Generate card number
    v_card_number := 'ID-' || v_user_type || '-' || v_ref_id;
    
    -- Check if user already has an active card
    UPDATE IDCards
    SET Status = 'Expired',
        UpdatedAt = CURRENT_TIMESTAMP
    WHERE UserID = p_user_id
    AND Status = 'Active';
    
    -- Create new ID card
    INSERT INTO IDCards (
        UserID, CardNumber, IssueDate, ExpiryDate, 
        Status, IssuedBy
    ) VALUES (
        p_user_id, v_card_number, SYSDATE, ADD_MONTHS(SYSDATE, p_expiry_years * 12),
        'Active', p_issued_by
    );
    
    COMMIT;
    p_result := 'ID Card generated successfully: ' || v_card_number;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_result := 'Error: ' || SQLERRM;
END generate_id_card;
/

-- ORACLE APEX REPORT QUERIES

-- Student Directory Report
CREATE OR REPLACE VIEW student_directory AS
SELECT 
    s.StudentID,
    s.StudentNumber,
    s.FirstName || ' ' || NVL(s.MiddleName || ' ', '') || s.LastName AS FullName,
    s.Gender,
    s.DateOfBirth,
    TRUNC(MONTHS_BETWEEN(SYSDATE, s.DateOfBirth) / 12) AS Age,
    s.Phone,
    s.Email,
    c.Name AS ClassName,
    p.Name AS Program,
    s.Status,
    g.FirstName || ' ' || g.LastName AS PrimaryGuardian,
    g.Phone AS GuardianPhone
FROM Students s
LEFT JOIN StudentClassEnrollments sce ON s.StudentID = sce.StudentID AND sce.Status = 'Active'
LEFT JOIN Classes c ON sce.ClassID = c.ClassID
LEFT JOIN Programs p ON c.ProgramID = p.ProgramID
LEFT JOIN StudentGuardians sg ON s.StudentID = sg.StudentID AND sg.IsPrimary = 1
LEFT JOIN Guardians g ON sg.GuardianID = g.GuardianID;


-- ORACLE APEX INTERACTIVE REPORTS AND DASHBOARDS

-- Attendance Summary Report
CREATE OR REPLACE VIEW attendance_summary AS
SELECT 
    c.Name AS ClassName,
    sub.Name AS SubjectName,
    t.FirstName || ' ' || t.LastName AS Teacher,
    sa.Date,
    COUNT(sa.StudentID) AS TotalStudents,
    SUM(CASE WHEN sa.Status = 'Present' THEN 1 ELSE 0 END) AS Present,
    SUM(CASE WHEN sa.Status = 'Absent' THEN 1 ELSE 0 END) AS Absent,
    SUM(CASE WHEN sa.Status = 'Late' THEN 1 ELSE 0 END) AS Late,
    SUM(CASE WHEN sa.Status = 'Excused' THEN 1 ELSE 0 END) AS Excused,
    ROUND(SUM(CASE WHEN sa.Status = 'Present' THEN 1 ELSE 0 END) / COUNT(sa.StudentID) * 100, 2) AS AttendancePercentage
FROM StudentAttendance sa
JOIN ClassSubjects cs ON sa.ClassSubjectID = cs.ClassSubjectID
JOIN Classes c ON cs.ClassID = c.ClassID
JOIN Subjects sub ON cs.SubjectID = sub.SubjectID
JOIN Teachers t ON cs.TeacherID = t.TeacherID
GROUP BY c.Name, sub.Name, t.FirstName || ' ' || t.LastName, sa.Date
ORDER BY sa.Date DESC, c.Name, sub.Name;

-- Fee Collection Report
CREATE OR REPLACE VIEW fee_collection_report AS
SELECT 
    ay.Name AS AcademicYear,
    fc.Name AS FeeCategory,
    SUM(sf.NetAmount) AS TotalDue,
    SUM(CASE WHEN sf.Status = 'Paid' THEN sf.NetAmount ELSE 0 END) AS PaidAmount,
    SUM(CASE WHEN sf.Status = 'Partially Paid' THEN 
        (SELECT SUM(fp.Amount) FROM FeePayments fp WHERE fp.StudentFeeID = sf.StudentFeeID)
        ELSE 0 END) AS PartiallyPaidAmount,
    SUM(CASE WHEN sf.Status IN ('Unpaid', 'Overdue') THEN sf.NetAmount ELSE 0 END) AS UnpaidAmount,
    ROUND((SUM(CASE WHEN sf.Status = 'Paid' THEN sf.NetAmount ELSE 0 END) + 
           SUM(CASE WHEN sf.Status = 'Partially Paid' THEN 
               (SELECT SUM(fp.Amount) FROM FeePayments fp WHERE fp.StudentFeeID = sf.StudentFeeID)
               ELSE 0 END)) / SUM(sf.NetAmount) * 100, 2) AS CollectionPercentage
FROM StudentFees sf
JOIN FeeStructures fs ON sf.FeeStructureID = fs.FeeStructureID
JOIN FeeCategories fc ON fs.CategoryID = fc.CategoryID
JOIN AcademicYears ay ON fs.AcademicYearID = ay.AcademicYearID
GROUP BY ay.Name, fc.Name
ORDER BY ay.Name, fc.Name;

-- Exam Results Analysis
CREATE OR REPLACE VIEW exam_results_analysis AS
SELECT 
    e.Name AS ExamName,
    c.Name AS ClassName,
    sub.Name AS SubjectName,
    t.FirstName || ' ' || t.LastName AS Teacher,
    COUNT(DISTINCT ser.StudentID) AS TotalStudents,
    ROUND(AVG(ser.MarksObtained), 2) AS AverageMarks,
    MAX(ser.MarksObtained) AS HighestMarks,
    MIN(ser.MarksObtained) AS LowestMarks,
    ROUND(STDDEV(ser.MarksObtained), 2) AS StandardDeviation,
    SUM(CASE WHEN gs.Grade = 'A' OR gs.Grade = 'A+' THEN 1 ELSE 0 END) AS ACount,
    SUM(CASE WHEN gs.Grade = 'B' OR gs.Grade = 'B+' THEN 1 ELSE 0 END) AS BCount,
    SUM(CASE WHEN gs.Grade = 'C' OR gs.Grade = 'C+' THEN 1 ELSE 0 END) AS CCount,
    SUM(CASE WHEN gs.Grade = 'D' OR gs.Grade = 'D+' THEN 1 ELSE 0 END) AS DCount,
    SUM(CASE WHEN gs.Grade = 'F' THEN 1 ELSE 0 END) AS FCount
FROM StudentExamResults ser
JOIN SubjectExams se ON ser.SubjectExamID = se.SubjectExamID
JOIN Exams e ON se.ExamID = e.ExamID
JOIN ClassSubjects cs ON se.ClassSubjectID = cs.ClassSubjectID
JOIN Classes c ON cs.ClassID = c.ClassID
JOIN Subjects sub ON cs.SubjectID = sub.SubjectID
JOIN Teachers t ON cs.TeacherID = t.TeacherID
JOIN GradingScales gs ON ser.GradeID = gs.GradeID
GROUP BY e.Name, c.Name, sub.Name, t.FirstName || ' ' || t.LastName
ORDER BY e.Name, c.Name, sub.Name;

-- Student Performance Report
CREATE OR REPLACE VIEW student_performance_report AS
SELECT 
    s.StudentID,
    s.StudentNumber,
    s.FirstName || ' ' || NVL(s.MiddleName || ' ', '') || s.LastName AS StudentName,
    c.Name AS ClassName,
    e.Name AS ExamName,
    rc.TotalMarks,
    rc.AveragePercentage,
    rc.CGPA,
    rc.Rank,
    COUNT(DISTINCT ser.SubjectExamID) AS SubjectsCount,
    SUM(CASE WHEN gs.Grade = 'F' THEN 1 ELSE 0 END) AS FailedSubjects
FROM ReportCards rc
JOIN Students s ON rc.StudentID = s.StudentID
JOIN Classes c ON rc.ClassID = c.ClassID
JOIN Exams e ON rc.ExamID = e.ExamID
LEFT JOIN StudentExamResults ser ON s.StudentID = ser.StudentID
LEFT JOIN SubjectExams se ON ser.SubjectExamID = se.SubjectExamID AND se.ExamID = e.ExamID
LEFT JOIN GradingScales gs ON ser.GradeID = gs.GradeID
GROUP BY s.StudentID, s.StudentNumber, s.FirstName || ' ' || NVL(s.MiddleName || ' ', '') || s.LastName,
         c.Name, e.Name, rc.TotalMarks, rc.AveragePercentage, rc.CGPA, rc.Rank
ORDER BY c.Name, rc.Rank;

-- Library Analytics
CREATE OR REPLACE VIEW library_analytics AS
SELECT 
    (SELECT COUNT(*) FROM Books) AS TotalBooks,
    (SELECT COUNT(*) FROM BookCopies) AS TotalCopies,
    (SELECT COUNT(*) FROM BookCopies WHERE Status = 'Available') AS AvailableCopies,
    (SELECT COUNT(*) FROM BookCopies WHERE Status = 'Issued') AS IssuedCopies,
    (SELECT COUNT(*) FROM BookIssues WHERE Status = 'Issued') AS CurrentIssues,
    (SELECT COUNT(*) FROM BookIssues WHERE Status = 'Overdue') AS OverdueIssues,
    (SELECT AVG(bi.ReturnDate - bi.IssueDate) FROM BookIssues bi WHERE bi.ReturnDate IS NOT NULL) AS AvgBorrowDuration,
    (SELECT SUM(FineAmount) FROM BookIssues WHERE Status = 'Returned' AND FineAmount > 0) AS TotalFinesCollected,
    (SELECT COUNT(DISTINCT MemberID) FROM BookIssues WHERE IssueDate >= ADD_MONTHS(SYSDATE, -1)) AS ActiveReadersLastMonth
FROM DUAL;

-- Most Popular Books Report
CREATE OR REPLACE VIEW popular_books_report AS
SELECT 
    b.BookID,
    b.Title,
    b.Author,
    bc.Name AS Category,
    COUNT(bi.IssueID) AS TimesIssued,
    AVG(bi.ReturnDate - bi.IssueDate) AS AvgReadTime
FROM Books b
JOIN BookCategories bc ON b.CategoryID = bc.CategoryID
JOIN BookCopies bcopy ON b.BookID = bcopy.BookID
JOIN BookIssues bi ON bcopy.CopyID = bi.CopyID
WHERE bi.IssueDate >= ADD_MONTHS(SYSDATE, -6)
GROUP BY b.BookID, b.Title, b.Author, bc.Name
ORDER BY COUNT(bi.IssueID) DESC;

-- APEX PACKAGES FOR APPLICATION FUNCTIONALITY

-- Student Management Package
CREATE OR REPLACE PACKAGE student_management AS
    PROCEDURE search_students(
        p_search_term IN VARCHAR2,
        p_class_id IN NUMBER DEFAULT NULL,
        p_status IN VARCHAR2 DEFAULT NULL
    );
    
    PROCEDURE update_student_status(
        p_student_id IN NUMBER,
        p_new_status IN VARCHAR2,
        p_result OUT VARCHAR2
    );
    
    PROCEDURE transfer_student(
        p_student_id IN NUMBER,
        p_new_class_id IN NUMBER,
        p_result OUT VARCHAR2
    );
    
    PROCEDURE get_student_details(
        p_student_id IN NUMBER,
        p_student_info OUT SYS_REFCURSOR
    );
END student_management;
/

CREATE OR REPLACE PACKAGE BODY student_management AS
    PROCEDURE search_students(
        p_search_term IN VARCHAR2,
        p_class_id IN NUMBER DEFAULT NULL,
        p_status IN VARCHAR2 DEFAULT NULL
    ) IS
        v_query VARCHAR2(4000);
    BEGIN
        v_query := 'SELECT s.StudentID, s.StudentNumber, s.FirstName, s.LastName, 
                          s.Phone, s.Email, c.Name AS ClassName, s.Status
                   FROM Students s
                   LEFT JOIN StudentClassEnrollments sce ON s.StudentID = sce.StudentID 
                   LEFT JOIN Classes c ON sce.ClassID = c.ClassID
                   WHERE 1=1';
        
        IF p_search_term IS NOT NULL THEN
            v_query := v_query || ' AND (
                LOWER(s.FirstName) LIKE ''%' || LOWER(p_search_term) || '%'' OR
                LOWER(s.LastName) LIKE ''%' || LOWER(p_search_term) || '%'' OR
                LOWER(s.StudentNumber) LIKE ''%' || LOWER(p_search_term) || '%'' OR
                LOWER(s.Email) LIKE ''%' || LOWER(p_search_term) || '%'' OR
                LOWER(s.Phone) LIKE ''%' || LOWER(p_search_term) || '%''
            )';
        END IF;
        
        IF p_class_id IS NOT NULL THEN
            v_query := v_query || ' AND sce.ClassID = ' || p_class_id;
        END IF;
        
        IF p_status IS NOT NULL THEN
            v_query := v_query || ' AND s.Status = ''' || p_status || '''';
        END IF;
        
        v_query := v_query || ' ORDER BY s.LastName, s.FirstName';
        
        -- In APEX, you would use this SQL in an interactive report
        -- For now, we'll just return the query as a debug message
        APEX_DEBUG.MESSAGE(v_query);
    END search_students;
    
    PROCEDURE update_student_status(
        p_student_id IN NUMBER,
        p_new_status IN VARCHAR2,
        p_result OUT VARCHAR2
    ) IS
    BEGIN
        UPDATE Students
        SET Status = p_new_status,
            UpdatedAt = CURRENT_TIMESTAMP
        WHERE StudentID = p_student_id;
        
        IF SQL%ROWCOUNT = 1 THEN
            -- Log the status change
            INSERT INTO ActivityLogs (
                UserID, Activity, IPAddress
            ) VALUES (
                APEX_UTIL.GET_SESSION_STATE('USER_ID'),
                'Updated student ID ' || p_student_id || ' status to ' || p_new_status,
                OWA_UTIL.GET_CGI_ENV('REMOTE_ADDR')
            );
            
            COMMIT;
            p_result := 'Status updated successfully.';
        ELSE
            p_result := 'Student not found.';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_result := 'Error: ' || SQLERRM;
    END update_student_status;
    
    PROCEDURE transfer_student(
        p_student_id IN NUMBER,
        p_new_class_id IN NUMBER,
        p_result OUT VARCHAR2
    ) IS
        v_old_class_id NUMBER;
        v_student_name VARCHAR2(100);
        v_new_class_name VARCHAR2(100);
    BEGIN
        -- Get student name
        SELECT FirstName || ' ' || LastName INTO v_student_name
        FROM Students
        WHERE StudentID = p_student_id;
        
        -- Get new class name
        SELECT Name INTO v_new_class_name
        FROM Classes
        WHERE ClassID = p_new_class_id;
        
        -- Check for existing enrollment and get old class ID
        BEGIN
            SELECT ClassID INTO v_old_class_id
            FROM StudentClassEnrollments
            WHERE StudentID = p_student_id
            AND Status = 'Active';
            
            -- Update existing enrollment to inactive
            UPDATE StudentClassEnrollments
            SET Status = 'Completed',
                UpdatedAt = CURRENT_TIMESTAMP
            WHERE StudentID = p_student_id
            AND ClassID = v_old_class_id
            AND Status = 'Active';
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_old_class_id := NULL;
        END;
        
        -- Create new enrollment
        INSERT INTO StudentClassEnrollments (
            StudentID, ClassID, EnrollmentDate, Status
        ) VALUES (
            p_student_id, p_new_class_id, SYSDATE, 'Active'
        );
        
        -- Log the transfer
        INSERT INTO ActivityLogs (
            UserID, Activity, IPAddress
        ) VALUES (
            APEX_UTIL.GET_SESSION_STATE('USER_ID'),
            'Transferred student ' || v_student_name || ' to class ' || v_new_class_name,
            OWA_UTIL.GET_CGI_ENV('REMOTE_ADDR')
        );
        
        COMMIT;
        p_result := 'Student transferred successfully to ' || v_new_class_name;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_result := 'Error: ' || SQLERRM;
    END transfer_student;
    
    PROCEDURE get_student_details(
        p_student_id IN NUMBER,
        p_student_info OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_student_info FOR
            SELECT 
                s.StudentID,
                s.StudentNumber,
                s.FirstName,
                s.MiddleName,
                s.LastName,
                s.DateOfBirth,
                s.Gender,
                s.Address,
                s.Phone,
                s.Email,
                s.EnrollmentDate,
                s.Status,
                c.Name AS CurrentClass,
                c.ClassID,
                p.Name AS Program,
                p.ProgramID,
                g.FirstName || ' ' || g.LastName AS GuardianName,
                g.Phone AS GuardianPhone,
                g.Email AS GuardianEmail,
                g.Relationship AS GuardianRelationship,
                ic.CardNumber AS IDCardNumber,
                ic.ExpiryDate AS IDCardExpiry
            FROM Students s
            LEFT JOIN StudentClassEnrollments sce ON s.StudentID = sce.StudentID AND sce.Status = 'Active'
            LEFT JOIN Classes c ON sce.ClassID = c.ClassID
            LEFT JOIN Programs p ON c.ProgramID = p.ProgramID
            LEFT JOIN StudentGuardians sg ON s.StudentID = sg.StudentID AND sg.IsPrimary = 1
            LEFT JOIN Guardians g ON sg.GuardianID = g.GuardianID
            LEFT JOIN Users u ON s.UserID = u.UserID
            LEFT JOIN IDCards ic ON u.UserID = ic.UserID AND ic.Status = 'Active'
            WHERE s.StudentID = p_student_id;
    END get_student_details;
END student_management;
/

-- Exam Management Package
CREATE OR REPLACE PACKAGE exam_management AS
    PROCEDURE schedule_exam(
        p_exam_type_id IN NUMBER,
        p_term_id IN NUMBER,
        p_name IN VARCHAR2,
        p_start_date IN DATE,
        p_end_date IN DATE,
        p_description IN VARCHAR2,
        p_result OUT VARCHAR2,
        p_exam_id OUT NUMBER
    );
    
    PROCEDURE schedule_subject_exam(
        p_exam_id IN NUMBER,
        p_class_subject_id IN NUMBER,
        p_exam_date IN DATE,
        p_start_time IN VARCHAR2,
        p_end_time IN VARCHAR2,
        p_total_marks IN NUMBER,
        p_pass_marks IN NUMBER,
        p_room IN VARCHAR2,
        p_result OUT VARCHAR2
    );
    
    PROCEDURE record_exam_result(
        p_student_id IN NUMBER,
        p_subject_exam_id IN NUMBER,
        p_marks_obtained IN NUMBER,
        p_evaluated_by IN NUMBER,
        p_remarks IN VARCHAR2,
        p_result OUT VARCHAR2
    );
    
    PROCEDURE publish_report_cards(
        p_class_id IN NUMBER,
        p_exam_id IN NUMBER,
        p_result OUT VARCHAR2
    );
END exam_management;
/

CREATE OR REPLACE PACKAGE BODY exam_management AS
    PROCEDURE schedule_exam(
        p_exam_type_id IN NUMBER,
        p_term_id IN NUMBER,
        p_name IN VARCHAR2,
        p_start_date IN DATE,
        p_end_date IN DATE,
        p_description IN VARCHAR2,
        p_result OUT VARCHAR2,
        p_exam_id OUT NUMBER
    ) IS
    BEGIN
        INSERT INTO Exams (
            ExamTypeID, TermID, Name, StartDate, EndDate, Description
        ) VALUES (
            p_exam_type_id, p_term_id, p_name, p_start_date, p_end_date, p_description
        ) RETURNING ExamID INTO p_exam_id;
        
        COMMIT;
        p_result := 'Exam scheduled successfully.';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_result := 'Error: ' || SQLERRM;
    END schedule_exam;
    
    PROCEDURE schedule_subject_exam(
        p_exam_id IN NUMBER,
        p_class_subject_id IN NUMBER,
        p_exam_date IN DATE,
        p_start_time IN VARCHAR2,
        p_end_time IN VARCHAR2,
        p_total_marks IN NUMBER,
        p_pass_marks IN NUMBER,
        p_room IN VARCHAR2,
        p_result OUT VARCHAR2
    ) IS
    BEGIN
        INSERT INTO SubjectExams (
            ExamID, ClassSubjectID, ExamDate, StartTime, EndTime, 
            TotalMarks, PassMarks, Room
        ) VALUES (
            p_exam_id, p_class_subject_id, p_exam_date, 
            TO_DATE(p_start_time, 'HH24:MI'), 
            TO_DATE(p_end_time, 'HH24:MI'),
            p_total_marks, p_pass_marks, p_room
        );
        
        COMMIT;
        p_result := 'Subject exam scheduled successfully.';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_result := 'Error: ' || SQLERRM;
    END schedule_subject_exam;
    
    PROCEDURE record_exam_result(
        p_student_id IN NUMBER,
        p_subject_exam_id IN NUMBER,
        p_marks_obtained IN NUMBER,
        p_evaluated_by IN NUMBER,
        p_remarks IN VARCHAR2,
        p_result OUT VARCHAR2
    ) IS
        v_pass_marks NUMBER;
        v_total_marks NUMBER;
        v_grade_id NUMBER;
    BEGIN
        -- Get exam details
        SELECT TotalMarks, PassMarks INTO v_total_marks, v_pass_marks
        FROM SubjectExams
        WHERE SubjectExamID = p_subject_exam_id;
        
        -- Validate marks
        IF p_marks_obtained < 0 OR p_marks_obtained > v_total_marks THEN
            p_result := 'Error: Invalid marks. Must be between 0 and ' || v_total_marks;
            RETURN;
        END IF;
        
        -- Determine grade
        SELECT GradeID INTO v_grade_id
        FROM GradingScales
        WHERE p_marks_obtained BETWEEN MinMarks AND MaxMarks;
        
        -- Check if result already exists
        BEGIN
            UPDATE StudentExamResults
            SET MarksObtained = p_marks_obtained,
                GradeID = v_grade_id,
                Remarks = p_remarks,
                EvaluatedBy = p_evaluated_by,
                UpdatedAt = CURRENT_TIMESTAMP
            WHERE StudentID = p_student_id
            AND SubjectExamID = p_subject_exam_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                -- Insert new result
                INSERT INTO StudentExamResults (
                    StudentID, SubjectExamID, MarksObtained, 
                    GradeID, Remarks, EvaluatedBy
                ) VALUES (
                    p_student_id, p_subject_exam_id, p_marks_obtained,
                    v_grade_id, p_remarks, p_evaluated_by
                );
            END IF;
            
            COMMIT;
            p_result := 'Exam result recorded successfully.';
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                p_result := 'Error: ' || SQLERRM;
        END;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_result := 'Error: Subject exam or grading scale not found.';
        WHEN OTHERS THEN
            p_result := 'Error: ' || SQLERRM;
    END record_exam_result;
    
    PROCEDURE publish_report_cards(
        p_class_id IN NUMBER,
        p_exam_id IN NUMBER,
        p_result OUT VARCHAR2
    ) IS
    BEGIN
        -- First, generate report cards (in case they don't exist)
        generate_report_cards(p_class_id, p_exam_id);
        
        -- Update status to published
        UPDATE ReportCards
        SET Status = 'Published',
            UpdatedAt = CURRENT_TIMESTAMP
        WHERE ClassID = p_class_id
        AND ExamID = p_exam_id
        AND Status = 'Draft';
        
        -- Send notifications to students and guardians
        FOR student_rec IN (
            SELECT s.StudentID, s.FirstName || ' ' || s.LastName AS StudentName,
                   rc.ReportCardID, u.UserID, g.GuardianID, gu.UserID AS GuardianUserID
            FROM ReportCards rc
            JOIN Students s ON rc.StudentID = s.StudentID
            JOIN Users u ON s.UserID = u.UserID
            LEFT JOIN StudentGuardians sg ON s.StudentID = sg.StudentID AND sg.IsPrimary = 1
            LEFT JOIN Guardians g ON sg.GuardianID = g.GuardianID
            LEFT JOIN Users gu ON g.UserID = gu.UserID
            WHERE rc.ClassID = p_class_id
            AND rc.ExamID = p_exam_id
            AND rc.Status = 'Published'
        )
        LOOP
            -- Notify student
            INSERT INTO Notifications (
                TypeID, UserID, Title, Message
            ) VALUES (
                1, -- Assuming 1 is the TypeID for "Report Card"
                student_rec.UserID,
                'Report Card Published',
                'Your report card for the recent examination is now available. Check your academic records.'
            );
            
            -- Notify guardian if exists
            IF student_rec.GuardianUserID IS NOT NULL THEN
                INSERT INTO Notifications (
                    TypeID, UserID, Title, Message
                ) VALUES (
                    1, -- Assuming 1 is the TypeID for "Report Card"
                    student_rec.GuardianUserID,
                    'Report Card Published',
                    'The report card for ' || student_rec.StudentName || ' is now available. Check academic records.'
                );
            END IF;
        END LOOP;
        
        COMMIT;
        p_result := 'Report cards published successfully.';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_result := 'Error: ' || SQLERRM;
    END publish_report_cards;
END exam_management;
/

-- APEX APPLICATIONS - PAGE DEFINITIONS

-- Oracle APEX uses declarative application development. Here are some key page definition scripts that
-- would typically be exported from APEX itself. This is a simplified representation for demonstration purposes.

-- Login Page (Page 1)
DECLARE
    l_app_id NUMBER := 100; -- Application ID
    l_page_id NUMBER := 1;  -- Page ID
BEGIN
    -- Create Login Page
    APEX_APPLICATION_PAGE.CREATE_PAGE(
        p_application_id => l_app_id,
        p_page_id => l_page_id,
        p_name => 'Login',
        p_page_mode => 'Normal',
        p_page_template => 'Login',
        p_page_css_classes => 'login-page',
        p_step_title => 'Login - School Management System'
    );
    
    -- Add Login Region
    APEX_APPLICATION_PAGE.CREATE_REGION(
        p_application_id => l_app_id,
        p_page_id => l_page_id,
        p_region_id => 1,
        p_region_name => 'Login',
        p_template => 'Login Region',
        p_display_sequence => 10,
        p_region_template_options => 'login-region',
        p_plug_source => NULL
    );
    
    -- Add Username Item
    APEX_APPLICATION_PAGE.CREATE_PAGE_ITEM(
        p_application_id => l_app_id,
        p_page_id => l_page_id,
        p_region_id => 1,
        p_item_id => 1,
        p_item_name => 'P1_USERNAME',
        p_display_sequence => 10,
        p_data_type => 'VARCHAR2',
        p_is_required => true,
        p_item_type => 'Text Field',
        p_prompt => 'Username',
        p_lov_display_null => false,
        p_lov_display_extra => false
    );
    
    -- Add Password Item
    APEX_APPLICATION_PAGE.CREATE_PAGE_ITEM(
        p_application_id => l_app_id,
        p_page_id => l_page_id,
        p_region_id => 1,
        p_item_id => 2,
        p_item_name => 'P1_PASSWORD',
        p_display_sequence => 20,
        p_data_type => 'VARCHAR2',
        p_is_required => true,
        p_item_type => 'Password',
        p_prompt => 'Password',
        p_lov_display_null => false,
        p_lov_display_extra => false
    );
    
    -- Add Login Button
    APEX_APPLICATION_PAGE.CREATE_BUTTON(
        p_application_id => l_app_id,
        p_page_id => l_page_id,
        p_button_name => 'LOGIN',
        p_button_sequence => 30, 
        p_button_image => 'TEXT',
        p_button_image_alt => 'Login',
        p_button_position => 'REGION_TEMPLATE_CREATE',
        p_button_alignment => 'CENTER',
        p_button_redirect_url => NULL,
        p_button_execute_validations => true
    );
    
    -- Add Login Process
    APEX_APPLICATION_PAGE.CREATE_PAGE_PROCESS(
        p_application_id => l_app_id,
        p_page_id => l_page_id,
        p_process_name => 'Login',
        p_process_type => 'PL/SQL Anonymous Block',
        p_process_point => 'AFTER_SUBMIT',
        p_process_source => 'DECLARE
    l_username VARCHAR2(255) := :P1_USERNAME;
    l_password VARCHAR2(255) := :P1_PASSWORD;
    l_user_id NUMBER;
    l_user_type VARCHAR2(20);
    l_is_valid BOOLEAN;
BEGIN
    l_is_valid := user_auth.validate_credentials(l_username, l_password);
    
    IF l_is_valid THEN
        -- Get user details
        SELECT UserID, UserType
        INTO l_user_id, l_user_type
        FROM Users
        WHERE LOWER(Username) = LOWER(l_username);
        
        -- Create session
        user_auth.create_user_session(l_user_id, l_username, l_user_type);
        
        -- Redirect based on user type
        CASE l_user_type
            WHEN ''Admin'' THEN
                :P1_REDIRECT := ''2''; -- Admin Dashboard
            WHEN ''Teacher'' THEN
                :P1_REDIRECT := ''3''; -- Teacher Dashboard
            WHEN ''Student'' THEN
                :P1_REDIRECT := ''4''; -- Student Dashboard
            WHEN ''Guardian'' THEN
                :P1_REDIRECT := ''5''; -- Guardian Dashboard
            ELSE
                :P1_REDIRECT := ''2''; -- Default to Admin
        END CASE;
    ELSE
        -- Invalid login
        apex_error.add_error(
            p_message => ''Invalid username or password.'',
            p_display_location => apex_error.c_inline_in_notification
        );
    END IF;
END;',
        p_process_error_message => 'Login Failed',
        p_process_success_message => 'Login Successful',
        p_process_is_stateful_set => true
    );
    
    -- Add Redirect After Login
    APEX_APPLICATION_PAGE.CREATE_BRANCH(
        p_application_id => l_app_id,
        p_page_id => l_page_id,
        p_branch_name => 'Go To Dashboard',
        p_branch_point => 'AFTER_PROCESSING',
        p_branch_type => 'BRANCH_TO_PAGE_ACCEPT',
        p_branch_sequence => 10,
        p_branch_condition_type => 'ITEM_IS_NOT_NULL',
        p_branch_condition => 'P1_REDIRECT',
        p_branch_target_page => ':P1_REDIRECT'
    );
END;
/

-- Admin Dashboard Page (Page 2)
DECLARE
    l_app_id NUMBER := 100; -- Application ID
    l_page_id NUMBER := 2;  -- Page ID