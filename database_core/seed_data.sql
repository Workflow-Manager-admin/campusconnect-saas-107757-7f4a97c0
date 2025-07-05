-- Campus Connect SaaS Platform Seed Data
-- Sample data for development and testing

-- Insert Super Admin user
INSERT INTO users (id, email, password_hash, first_name, last_name, role, is_active, email_verified) VALUES
('00000000-0000-0000-0000-000000000001', 'admin@campusconnect.com', crypt('admin123', gen_salt('bf')), 'Super', 'Admin', 'super_admin', true, true);

-- Insert sample colleges
INSERT INTO colleges (id, name, code, address, city, state, contact_email, contact_phone, is_active, created_by) VALUES
('11111111-1111-1111-1111-111111111111', 'Indian Institute of Technology Delhi', 'IITD', 'Hauz Khas, New Delhi', 'New Delhi', 'Delhi', 'placements@iitd.ac.in', '+91-11-2659-1000', true, '00000000-0000-0000-0000-000000000001'),
('22222222-2222-2222-2222-222222222222', 'National Institute of Technology Trichy', 'NITT', 'Tiruchirappalli', 'Tiruchirappalli', 'Tamil Nadu', 'placements@nitt.edu', '+91-431-250-3000', true, '00000000-0000-0000-0000-000000000001'),
('33333333-3333-3333-3333-333333333333', 'Birla Institute of Technology and Science Pilani', 'BITS', 'Pilani', 'Pilani', 'Rajasthan', 'placements@pilani.bits-pilani.ac.in', '+91-1596-242-204', true, '00000000-0000-0000-0000-000000000001');

-- Insert TPO users
INSERT INTO users (id, email, password_hash, first_name, last_name, phone, role, is_active, email_verified, created_by) VALUES
('tpo11111-1111-1111-1111-111111111111', 'tpo@iitd.ac.in', crypt('tpo123', gen_salt('bf')), 'Rajesh', 'Kumar', '+91-9876543210', 'tpo', true, true, '00000000-0000-0000-0000-000000000001'),
('tpo22222-2222-2222-2222-222222222222', 'tpo@nitt.edu', crypt('tpo123', gen_salt('bf')), 'Priya', 'Sharma', '+91-9876543211', 'tpo', true, true, '00000000-0000-0000-0000-000000000001'),
('tpo33333-3333-3333-3333-333333333333', 'tpo@pilani.bits-pilani.ac.in', crypt('tpo123', gen_salt('bf')), 'Amit', 'Patel', '+91-9876543212', 'tpo', true, true, '00000000-0000-0000-0000-000000000001');

-- Link TPOs to colleges
INSERT INTO college_admins (user_id, college_id, designation, department, is_primary, permissions) VALUES
('tpo11111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Training & Placement Officer', 'Career Services', true, '{"manage_jobs": true, "manage_students": true, "view_analytics": true}'),
('tpo22222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', 'Training & Placement Officer', 'Career Services', true, '{"manage_jobs": true, "manage_students": true, "view_analytics": true}'),
('tpo33333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-333333333333', 'Training & Placement Officer', 'Career Services', true, '{"manage_jobs": true, "manage_students": true, "view_analytics": true}');

-- Insert sample student users
INSERT INTO users (id, email, password_hash, first_name, last_name, phone, role, is_active, email_verified, created_by) VALUES
('std11111-1111-1111-1111-111111111111', 'student1@iitd.ac.in', crypt('student123', gen_salt('bf')), 'Rahul', 'Gupta', '+91-9876543213', 'student', true, true, 'tpo11111-1111-1111-1111-111111111111'),
('std11111-1111-1111-1111-111111111112', 'student2@iitd.ac.in', crypt('student123', gen_salt('bf')), 'Sneha', 'Reddy', '+91-9876543214', 'student', true, true, 'tpo11111-1111-1111-1111-111111111111'),
('std11111-1111-1111-1111-111111111113', 'student3@iitd.ac.in', crypt('student123', gen_salt('bf')), 'Vikram', 'Singh', '+91-9876543215', 'student', true, true, 'tpo11111-1111-1111-1111-111111111111'),
('std22222-2222-2222-2222-222222222221', 'student1@nitt.edu', crypt('student123', gen_salt('bf')), 'Ananya', 'Iyer', '+91-9876543216', 'student', true, true, 'tpo22222-2222-2222-2222-222222222222'),
('std22222-2222-2222-2222-222222222222', 'student2@nitt.edu', crypt('student123', gen_salt('bf')), 'Karthik', 'Murthy', '+91-9876543217', 'student', true, true, 'tpo22222-2222-2222-2222-222222222222'),
('std33333-3333-3333-3333-333333333331', 'student1@pilani.bits-pilani.ac.in', crypt('student123', gen_salt('bf')), 'Meera', 'Joshi', '+91-9876543218', 'student', true, true, 'tpo33333-3333-3333-3333-333333333333');

-- Insert student profiles
INSERT INTO student_profiles (id, user_id, college_id, student_id, branch, year_of_study, semester, current_cgpa, total_cgpa, date_of_birth, gender, category, city, state, linkedin_url, github_url, skills, interests, is_placement_eligible, placement_status) VALUES
('stp11111-1111-1111-1111-111111111111', 'std11111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', '2020CS001', 'Computer Science', 4, 8, 8.5, 8.2, '2002-05-15', 'Male', 'General', 'Delhi', 'Delhi', 'https://linkedin.com/in/rahulgupta', 'https://github.com/rahulgupta', ARRAY['Python', 'Java', 'React', 'Node.js', 'PostgreSQL'], ARRAY['Web Development', 'Machine Learning', 'Data Science'], true, 'available'),
('stp11111-1111-1111-1111-111111111112', 'std11111-1111-1111-1111-111111111112', '11111111-1111-1111-1111-111111111111', '2020CS002', 'Computer Science', 4, 8, 9.1, 8.8, '2002-03-22', 'Female', 'General', 'Bangalore', 'Karnataka', 'https://linkedin.com/in/snehareddy', 'https://github.com/snehareddy', ARRAY['Python', 'Machine Learning', 'TensorFlow', 'Django', 'AWS'], ARRAY['AI/ML', 'Cloud Computing', 'Data Analytics'], true, 'available'),
('stp11111-1111-1111-1111-111111111113', 'std11111-1111-1111-1111-111111111113', '11111111-1111-1111-1111-111111111111', '2020EE001', 'Electrical Engineering', 4, 8, 7.8, 7.5, '2002-08-10', 'Male', 'OBC', 'Mumbai', 'Maharashtra', 'https://linkedin.com/in/vikramsingh', 'https://github.com/vikramsingh', ARRAY['C++', 'Python', 'MATLAB', 'Embedded Systems', 'IoT'], ARRAY['Embedded Systems', 'Robotics', 'IoT'], true, 'available'),
('stp22222-2222-2222-2222-222222222221', 'std22222-2222-2222-2222-222222222221', '22222222-2222-2222-2222-222222222222', '2020CS101', 'Computer Science', 4, 8, 8.9, 8.6, '2002-01-18', 'Female', 'General', 'Chennai', 'Tamil Nadu', 'https://linkedin.com/in/ananyaiyer', 'https://github.com/ananyaiyer', ARRAY['Java', 'Spring Boot', 'Angular', 'MySQL', 'Docker'], ARRAY['Full Stack Development', 'DevOps', 'System Design'], true, 'available'),
('stp22222-2222-2222-2222-222222222222', 'std22222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', '2020ME101', 'Mechanical Engineering', 4, 8, 7.2, 7.0, '2002-07-25', 'Male', 'SC', 'Coimbatore', 'Tamil Nadu', 'https://linkedin.com/in/karthikmurthy', NULL, ARRAY['CAD', 'SolidWorks', 'ANSYS', 'Python', 'Manufacturing'], ARRAY['Design', 'Manufacturing', 'Automation'], true, 'available'),
('stp33333-3333-3333-3333-333333333331', 'std33333-3333-3333-3333-333333333331', '33333333-3333-3333-3333-333333333333', '2020CS201', 'Computer Science', 4, 8, 8.7, 8.4, '2002-11-12', 'Female', 'General', 'Jaipur', 'Rajasthan', 'https://linkedin.com/in/meerajoshi', 'https://github.com/meerajoshi', ARRAY['Python', 'React', 'MongoDB', 'Express', 'Node.js'], ARRAY['Web Development', 'UI/UX', 'Product Management'], true, 'available');

-- Insert sample job postings
INSERT INTO job_postings (id, college_id, company_name, job_title, job_description, job_type, location, salary_min, salary_max, required_skills, preferred_skills, experience_required, eligibility_criteria, application_deadline, company_description, company_website, min_cgpa, allowed_branches, allowed_years, status, is_featured, created_by) VALUES
('job11111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Google', 'Software Engineer', 'Join our team to build innovative products that impact billions of users worldwide. Work on cutting-edge technologies and solve complex problems.', 'full_time', 'Bangalore, India', 1200000, 2000000, ARRAY['Python', 'Java', 'Data Structures', 'Algorithms'], ARRAY['Go', 'Kubernetes', 'GCP', 'Machine Learning'], 'Fresh Graduate', 'Minimum 8.0 CGPA required', '2024-08-15 23:59:59', 'Google is a multinational technology company focusing on search engine technology, online advertising, cloud computing, and more.', 'https://www.google.com', 8.0, ARRAY['Computer Science', 'Information Technology'], ARRAY[4], 'active', true, 'tpo11111-1111-1111-1111-111111111111'),
('job11111-1111-1111-1111-111111111112', '11111111-1111-1111-1111-111111111111', 'Microsoft', 'Data Scientist', 'Analyze large datasets to drive business decisions and develop machine learning models for Microsoft products.', 'full_time', 'Hyderabad, India', 1000000, 1800000, ARRAY['Python', 'R', 'Machine Learning', 'Statistics'], ARRAY['Azure', 'Power BI', 'SQL Server'], 'Fresh Graduate', 'Minimum 7.5 CGPA required', '2024-08-20 23:59:59', 'Microsoft is a leading technology company developing computer software, consumer electronics, and related services.', 'https://www.microsoft.com', 7.5, ARRAY['Computer Science', 'Mathematics', 'Statistics'], ARRAY[4], 'active', true, 'tpo11111-1111-1111-1111-111111111111'),
('job22222-2222-2222-2222-222222222221', '22222222-2222-2222-2222-222222222222', 'Amazon', 'Software Development Engineer', 'Build scalable systems and work on high-impact projects that serve millions of customers globally.', 'full_time', 'Chennai, India', 1300000, 2200000, ARRAY['Java', 'Python', 'System Design', 'Data Structures'], ARRAY['AWS', 'Docker', 'Microservices'], 'Fresh Graduate', 'Minimum 8.5 CGPA required', '2024-08-25 23:59:59', 'Amazon is a multinational technology company focusing on e-commerce, cloud computing, and artificial intelligence.', 'https://www.amazon.com', 8.5, ARRAY['Computer Science', 'Information Technology'], ARRAY[4], 'active', true, 'tpo22222-2222-2222-2222-222222222222'),
('job33333-3333-3333-3333-333333333331', '33333333-3333-3333-3333-333333333333', 'Flipkart', 'Product Manager', 'Drive product strategy and work with cross-functional teams to deliver exceptional user experiences.', 'full_time', 'Bangalore, India', 1500000, 2500000, ARRAY['Product Management', 'Analytics', 'Strategy'], ARRAY['SQL', 'A/B Testing', 'Agile'], 'Fresh Graduate', 'Minimum 8.0 CGPA required', '2024-08-30 23:59:59', 'Flipkart is Indias leading e-commerce marketplace offering a wide range of products.', 'https://www.flipkart.com', 8.0, ARRAY['Computer Science', 'MBA', 'Economics'], ARRAY[4], 'active', false, 'tpo33333-3333-3333-3333-333333333333'),
('job11111-1111-1111-1111-111111111113', '11111111-1111-1111-1111-111111111111', 'Tata Consultancy Services', 'Systems Engineer', 'Work on enterprise solutions and gain exposure to various technologies and domains.', 'full_time', 'Multiple Locations', 350000, 500000, ARRAY['Programming', 'Database', 'Communication'], ARRAY['Java', 'Python', 'SQL'], 'Fresh Graduate', 'Minimum 6.0 CGPA required', '2024-09-10 23:59:59', 'TCS is a global leader in IT services, consulting, and business solutions.', 'https://www.tcs.com', 6.0, ARRAY['Computer Science', 'Information Technology', 'Electronics', 'Electrical'], ARRAY[4], 'active', false, 'tpo11111-1111-1111-1111-111111111111');

-- Insert sample job applications
INSERT INTO job_applications (id, job_id, student_id, cover_letter, status, applied_at, score, feedback) VALUES
('app11111-1111-1111-1111-111111111111', 'job11111-1111-1111-1111-111111111111', 'stp11111-1111-1111-1111-111111111111', 'I am excited to apply for the Software Engineer position at Google. My experience with Python and Java aligns well with the requirements.', 'shortlisted', '2024-07-15 10:30:00', 85.5, 'Strong technical background, good problem-solving skills'),
('app11111-1111-1111-1111-111111111112', 'job11111-1111-1111-1111-111111111112', 'stp11111-1111-1111-1111-111111111112', 'I am passionate about data science and would love to contribute to Microsoft''s data-driven initiatives.', 'selected', '2024-07-16 14:20:00', 92.0, 'Excellent academic record, strong analytical skills'),
('app22222-2222-2222-2222-222222222221', 'job22222-2222-2222-2222-222222222221', 'stp22222-2222-2222-2222-222222222221', 'Amazon''s customer-centric approach aligns with my values. I am eager to contribute to building scalable systems.', 'applied', '2024-07-18 09:15:00', NULL, NULL),
('app33333-3333-3333-3333-333333333331', 'job33333-3333-3333-3333-333333333331', 'stp33333-3333-3333-3333-333333333331', 'I am interested in product management and believe my technical background will be valuable in this role.', 'applied', '2024-07-20 16:45:00', NULL, NULL);

-- Insert sample placement rounds
INSERT INTO placement_rounds (id, job_id, round_number, round_name, round_type, description, scheduled_at, duration_minutes, location, status, max_participants, created_by) VALUES
('rnd11111-1111-1111-1111-111111111111', 'job11111-1111-1111-1111-111111111111', 1, 'Online Assessment', 'written_test', 'Coding assessment covering data structures and algorithms', '2024-08-01 10:00:00', 120, 'Online', 'completed', 100, 'tpo11111-1111-1111-1111-111111111111'),
('rnd11111-1111-1111-1111-111111111112', 'job11111-1111-1111-1111-111111111111', 2, 'Technical Interview', 'technical_interview', 'Technical interview covering system design and coding', '2024-08-05 14:00:00', 60, 'Virtual', 'scheduled', 20, 'tpo11111-1111-1111-1111-111111111111'),
('rnd22222-2222-2222-2222-222222222221', 'job22222-2222-2222-2222-222222222221', 1, 'Online Test', 'written_test', 'Technical assessment and logical reasoning', '2024-08-10 09:00:00', 90, 'Online', 'scheduled', 50, 'tpo22222-2222-2222-2222-222222222222');

-- Insert sample placement status history
INSERT INTO placement_status_history (id, application_id, round_id, previous_status, new_status, changed_at, changed_by, reason, score, feedback) VALUES
('his11111-1111-1111-1111-111111111111', 'app11111-1111-1111-1111-111111111111', 'rnd11111-1111-1111-1111-111111111111', 'applied', 'shortlisted', '2024-08-02 18:00:00', 'tpo11111-1111-1111-1111-111111111111', 'Qualified online assessment', 85.5, 'Good performance in coding round'),
('his11111-1111-1111-1111-111111111112', 'app11111-1111-1111-1111-111111111112', NULL, 'applied', 'selected', '2024-08-05 20:00:00', 'tpo11111-1111-1111-1111-111111111111', 'Excellent interview performance', 92.0, 'Outstanding technical and communication skills');

-- Insert sample notifications
INSERT INTO notifications (id, college_id, title, message, type, target_roles, status, created_at, created_by) VALUES
('not11111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'New Job Posting: Google Software Engineer', 'A new job opportunity has been posted by Google. Application deadline: August 15, 2024.', 'in_app', ARRAY['student'], 'sent', '2024-07-10 12:00:00', 'tpo11111-1111-1111-1111-111111111111'),
('not22222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', 'Placement Drive Update', 'Amazon placement drive scheduled for August 25, 2024. Prepare well!', 'email', ARRAY['student'], 'sent', '2024-07-12 15:30:00', 'tpo22222-2222-2222-2222-222222222222');

-- Insert sample notification recipients
INSERT INTO notification_recipients (id, notification_id, user_id, status, sent_at, delivered_at) VALUES
('rec11111-1111-1111-1111-111111111111', 'not11111-1111-1111-1111-111111111111', 'std11111-1111-1111-1111-111111111111', 'delivered', '2024-07-10 12:01:00', '2024-07-10 12:01:00'),
('rec11111-1111-1111-1111-111111111112', 'not11111-1111-1111-1111-111111111111', 'std11111-1111-1111-1111-111111111112', 'delivered', '2024-07-10 12:01:00', '2024-07-10 12:01:00'),
('rec22222-2222-2222-2222-222222222221', 'not22222-2222-2222-2222-222222222222', 'std22222-2222-2222-2222-222222222221', 'delivered', '2024-07-12 15:31:00', '2024-07-12 15:31:00');

-- Insert sample document uploads
INSERT INTO document_uploads (id, user_id, college_id, entity_type, entity_id, document_type, file_name, file_path, file_size, mime_type, is_public, is_verified) VALUES
('doc11111-1111-1111-1111-111111111111', 'std11111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'user', 'std11111-1111-1111-1111-111111111111', 'resume', 'rahul_gupta_resume.pdf', '/uploads/resumes/rahul_gupta_resume.pdf', 245760, 'application/pdf', false, true),
('doc11111-1111-1111-1111-111111111112', 'std11111-1111-1111-1111-111111111112', '11111111-1111-1111-1111-111111111111', 'user', 'std11111-1111-1111-1111-111111111112', 'resume', 'sneha_reddy_resume.pdf', '/uploads/resumes/sneha_reddy_resume.pdf', 198432, 'application/pdf', false, true),
('doc11111-1111-1111-1111-111111111113', 'std11111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'user', 'std11111-1111-1111-1111-111111111111', 'photo', 'rahul_gupta_photo.jpg', '/uploads/photos/rahul_gupta_photo.jpg', 102400, 'image/jpeg', false, true);

-- Insert sample analytics logs
INSERT INTO analytics_logs (id, user_id, college_id, event_type, event_data, ip_address, session_id, created_at) VALUES
('log11111-1111-1111-1111-111111111111', 'std11111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'login', '{"device": "desktop", "browser": "chrome"}', '192.168.1.100', 'sess_123456', '2024-07-15 08:30:00'),
('log11111-1111-1111-1111-111111111112', 'std11111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'job_view', '{"job_id": "job11111-1111-1111-1111-111111111111", "company": "Google"}', '192.168.1.100', 'sess_123456', '2024-07-15 08:35:00'),
('log11111-1111-1111-1111-111111111113', 'std11111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'job_apply', '{"job_id": "job11111-1111-1111-1111-111111111111", "company": "Google"}', '192.168.1.100', 'sess_123456', '2024-07-15 10:30:00');

-- Insert sample audit trails
INSERT INTO audit_trails (id, user_id, college_id, entity_type, entity_id, action, old_values, new_values, ip_address, session_id, created_at) VALUES
('aud11111-1111-1111-1111-111111111111', 'tpo11111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'job_postings', 'job11111-1111-1111-1111-111111111111', 'create', NULL, '{"company_name": "Google", "job_title": "Software Engineer", "status": "active"}', '192.168.1.200', 'sess_tpo_123', '2024-07-10 11:00:00'),
('aud11111-1111-1111-1111-111111111112', 'tpo11111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'job_applications', 'app11111-1111-1111-1111-111111111111', 'update', '{"status": "applied"}', '{"status": "shortlisted"}', '192.168.1.200', 'sess_tpo_456', '2024-08-02 18:00:00');

-- Update applications count for job postings
UPDATE job_postings SET applications_count = (
    SELECT COUNT(*) FROM job_applications WHERE job_id = job_postings.id
);

-- Update views count for job postings (sample data)
UPDATE job_postings SET views_count = FLOOR(RANDOM() * 100) + 10;

-- Add some sample data for college admin permissions
UPDATE college_admins SET permissions = '{"manage_jobs": true, "manage_students": true, "manage_rounds": true, "view_analytics": true, "send_notifications": true, "manage_documents": true}';

-- Insert additional sample data for better testing
INSERT INTO users (id, email, password_hash, first_name, last_name, phone, role, is_active, email_verified, created_by) VALUES
('cadm1111-1111-1111-1111-111111111111', 'admin@iitd.ac.in', crypt('admin123', gen_salt('bf')), 'Dr. Sunita', 'Verma', '+91-11-2659-1001', 'college_admin', true, true, '00000000-0000-0000-0000-000000000001');

INSERT INTO college_admins (user_id, college_id, designation, department, is_primary, permissions) VALUES
('cadm1111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Dean of Student Affairs', 'Administration', false, '{"view_analytics": true, "manage_students": true}');

-- Print completion message
SELECT 'Campus Connect SaaS Platform seed data inserted successfully!' as message;
