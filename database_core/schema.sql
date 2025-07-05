-- CampusConnect SaaS Platform Database Schema
-- Comprehensive schema for campus recruitment management system

-- Enable UUID extension for generating unique identifiers
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom enum types
CREATE TYPE user_role AS ENUM ('student', 'tpo', 'super_admin');
CREATE TYPE application_status AS ENUM ('pending', 'accepted', 'rejected', 'withdrawn');
CREATE TYPE placement_round_status AS ENUM ('upcoming', 'ongoing', 'completed', 'cancelled');
CREATE TYPE notification_type AS ENUM ('email', 'sms', 'in_app');
CREATE TYPE document_type AS ENUM ('resume', 'cover_letter', 'transcript', 'certificate', 'photo', 'other');
CREATE TYPE job_type AS ENUM ('full_time', 'part_time', 'internship', 'contract');
CREATE TYPE audit_action AS ENUM ('create', 'update', 'delete', 'login', 'logout');

-- Users table - Central user management
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role user_role NOT NULL DEFAULT 'student',
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    phone VARCHAR(20),
    profile_picture_url TEXT,
    last_login TIMESTAMP WITH TIME ZONE,
    password_reset_token VARCHAR(255),
    password_reset_expires TIMESTAMP WITH TIME ZONE,
    verification_token VARCHAR(255),
    verification_expires TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Colleges table - Institution management
CREATE TABLE colleges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'India',
    pincode VARCHAR(20),
    phone VARCHAR(20),
    email VARCHAR(255),
    website VARCHAR(255),
    established_year INTEGER,
    logo_url TEXT,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Students table - Student profile management
CREATE TABLE students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    college_id UUID NOT NULL REFERENCES colleges(id) ON DELETE CASCADE,
    student_id VARCHAR(50) NOT NULL, -- College-specific student ID
    branch VARCHAR(100),
    year_of_study INTEGER,
    semester INTEGER,
    cgpa DECIMAL(4,2),
    percentage DECIMAL(5,2),
    date_of_birth DATE,
    gender VARCHAR(20),
    category VARCHAR(50), -- General, OBC, SC, ST, etc.
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    pincode VARCHAR(20),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    emergency_contact_relation VARCHAR(50),
    skills TEXT[], -- Array of skills
    achievements TEXT,
    projects TEXT,
    internships TEXT,
    certifications TEXT,
    languages TEXT[],
    hobbies TEXT,
    resume_url TEXT,
    is_placement_eligible BOOLEAN DEFAULT TRUE,
    placement_preference TEXT, -- Job preferences
    expected_salary INTEGER,
    preferred_locations TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(college_id, student_id)
);

-- Companies table - Recruiting companies
CREATE TABLE companies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    industry VARCHAR(100),
    website VARCHAR(255),
    logo_url TEXT,
    headquarters_location VARCHAR(255),
    company_size VARCHAR(50), -- startup, small, medium, large, enterprise
    founded_year INTEGER,
    contact_person_name VARCHAR(100),
    contact_person_email VARCHAR(255),
    contact_person_phone VARCHAR(20),
    hr_email VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Jobs table - Job postings
CREATE TABLE jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    job_type job_type NOT NULL DEFAULT 'full_time',
    location VARCHAR(255),
    salary_min INTEGER,
    salary_max INTEGER,
    currency VARCHAR(10) DEFAULT 'INR',
    experience_required VARCHAR(100), -- 0-2 years, 2-5 years, etc.
    skills_required TEXT[],
    qualification_required TEXT,
    eligibility_criteria TEXT,
    application_deadline DATE,
    interview_process TEXT,
    bond_details TEXT,
    other_benefits TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    posted_by UUID REFERENCES users(id), -- TPO who posted
    posted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Job College Mapping - Which colleges can apply for specific jobs
CREATE TABLE job_college_eligibility (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    college_id UUID NOT NULL REFERENCES colleges(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(job_id, college_id)
);

-- Applications table - Student job applications
CREATE TABLE applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    status application_status DEFAULT 'pending',
    cover_letter TEXT,
    resume_url TEXT,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status_updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status_updated_by UUID REFERENCES users(id),
    feedback TEXT,
    interview_date TIMESTAMP WITH TIME ZONE,
    interview_location VARCHAR(255),
    interview_mode VARCHAR(50), -- online, offline, hybrid
    interview_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(student_id, job_id)
);

-- Placement Rounds table - Recruitment rounds management
CREATE TABLE placement_rounds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    round_name VARCHAR(100) NOT NULL, -- Written Test, Technical Interview, HR Interview, etc.
    round_type VARCHAR(50), -- test, interview, group_discussion, etc.
    round_number INTEGER NOT NULL,
    description TEXT,
    scheduled_date DATE,
    scheduled_time TIME,
    duration_minutes INTEGER,
    location VARCHAR(255),
    mode VARCHAR(50), -- online, offline, hybrid
    max_participants INTEGER,
    instructions TEXT,
    status placement_round_status DEFAULT 'upcoming',
    results_published BOOLEAN DEFAULT FALSE,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Placement Round Participants - Track student participation in rounds
CREATE TABLE placement_round_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    placement_round_id UUID NOT NULL REFERENCES placement_rounds(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    application_id UUID NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    attendance_status VARCHAR(50) DEFAULT 'registered', -- registered, attended, absent, excused
    result VARCHAR(50), -- passed, failed, pending
    score DECIMAL(5,2),
    feedback TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(placement_round_id, student_id)
);

-- Notifications table - System notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type notification_type DEFAULT 'in_app',
    category VARCHAR(50), -- job_posting, application_update, round_schedule, etc.
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    scheduled_for TIMESTAMP WITH TIME ZONE,
    sent_at TIMESTAMP WITH TIME ZONE,
    email_sent BOOLEAN DEFAULT FALSE,
    sms_sent BOOLEAN DEFAULT FALSE,
    metadata JSONB, -- Additional data like job_id, application_id, etc.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Documents table - File management
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    original_name VARCHAR(255),
    file_path TEXT NOT NULL,
    file_url TEXT,
    file_type VARCHAR(50),
    file_size INTEGER,
    document_type document_type NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    verified_by UUID REFERENCES users(id),
    verified_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Audit Logs table - Activity tracking
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action audit_action NOT NULL,
    entity_type VARCHAR(50) NOT NULL, -- users, students, jobs, applications, etc.
    entity_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    session_id VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User Sessions table - Session management
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    refresh_token VARCHAR(255),
    ip_address INET,
    user_agent TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- College TPO Mapping - Associate TPOs with colleges
CREATE TABLE college_tpo_mapping (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    college_id UUID NOT NULL REFERENCES colleges(id) ON DELETE CASCADE,
    tpo_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT FALSE,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    assigned_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(college_id, tpo_id)
);

-- Analytics Views for reporting
CREATE VIEW student_placement_stats AS
SELECT 
    s.college_id,
    c.name as college_name,
    s.branch,
    s.year_of_study,
    COUNT(DISTINCT s.id) as total_students,
    COUNT(DISTINCT CASE WHEN app.status = 'accepted' THEN s.id END) as placed_students,
    COUNT(DISTINCT app.id) as total_applications,
    COUNT(DISTINCT CASE WHEN app.status = 'accepted' THEN app.id END) as successful_applications,
    AVG(CASE WHEN app.status = 'accepted' THEN j.salary_max END) as avg_salary_offered
FROM students s
LEFT JOIN colleges c ON s.college_id = c.id
LEFT JOIN applications app ON s.id = app.student_id
LEFT JOIN jobs j ON app.job_id = j.id
GROUP BY s.college_id, c.name, s.branch, s.year_of_study;

CREATE VIEW company_recruitment_stats AS
SELECT 
    comp.id,
    comp.name as company_name,
    comp.industry,
    COUNT(DISTINCT j.id) as total_jobs_posted,
    COUNT(DISTINCT app.id) as total_applications_received,
    COUNT(DISTINCT CASE WHEN app.status = 'accepted' THEN app.id END) as total_hires,
    AVG(j.salary_max) as avg_salary_offered,
    COUNT(DISTINCT app.student_id) as unique_applicants
FROM companies comp
LEFT JOIN jobs j ON comp.id = j.company_id
LEFT JOIN applications app ON j.id = app.job_id
GROUP BY comp.id, comp.name, comp.industry;

-- Create indexes for performance optimization
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_created_at ON users(created_at);

CREATE INDEX idx_students_user_id ON students(user_id);
CREATE INDEX idx_students_college_id ON students(college_id);
CREATE INDEX idx_students_student_id ON students(student_id);
CREATE INDEX idx_students_branch ON students(branch);
CREATE INDEX idx_students_year_of_study ON students(year_of_study);

CREATE INDEX idx_jobs_company_id ON jobs(company_id);
CREATE INDEX idx_jobs_is_active ON jobs(is_active);
CREATE INDEX idx_jobs_posted_at ON jobs(posted_at);
CREATE INDEX idx_jobs_application_deadline ON jobs(application_deadline);

CREATE INDEX idx_applications_student_id ON applications(student_id);
CREATE INDEX idx_applications_job_id ON applications(job_id);
CREATE INDEX idx_applications_status ON applications(status);
CREATE INDEX idx_applications_applied_at ON applications(applied_at);

CREATE INDEX idx_placement_rounds_job_id ON placement_rounds(job_id);
CREATE INDEX idx_placement_rounds_scheduled_date ON placement_rounds(scheduled_date);
CREATE INDEX idx_placement_rounds_status ON placement_rounds(status);

CREATE INDEX idx_notifications_recipient_id ON notifications(recipient_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);
CREATE INDEX idx_notifications_type ON notifications(type);

CREATE INDEX idx_documents_owner_id ON documents(owner_id);
CREATE INDEX idx_documents_document_type ON documents(document_type);
CREATE INDEX idx_documents_is_public ON documents(is_public);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_entity_type ON audit_logs(entity_type);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_session_token ON user_sessions(session_token);
CREATE INDEX idx_user_sessions_is_active ON user_sessions(is_active);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);

-- Create triggers for automatic timestamp updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to all tables with updated_at column
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_colleges_updated_at BEFORE UPDATE ON colleges FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_students_updated_at BEFORE UPDATE ON students FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON companies FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_jobs_updated_at BEFORE UPDATE ON jobs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_applications_updated_at BEFORE UPDATE ON applications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_placement_rounds_updated_at BEFORE UPDATE ON placement_rounds FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_placement_round_participants_updated_at BEFORE UPDATE ON placement_round_participants FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_documents_updated_at BEFORE UPDATE ON documents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_sessions_updated_at BEFORE UPDATE ON user_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert default super admin user
INSERT INTO users (
    email, 
    password_hash, 
    first_name, 
    last_name, 
    role, 
    is_active, 
    is_verified
) VALUES (
    'admin@campusconnect.com',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewI5gCUqSvAMhYFe', -- password: admin123
    'Super',
    'Admin',
    'super_admin',
    TRUE,
    TRUE
) ON CONFLICT (email) DO NOTHING;

-- Create function to get user with role information
CREATE OR REPLACE FUNCTION get_user_with_role(user_email VARCHAR)
RETURNS TABLE (
    id UUID,
    email VARCHAR,
    first_name VARCHAR,
    last_name VARCHAR,
    role user_role,
    is_active BOOLEAN,
    is_verified BOOLEAN,
    phone VARCHAR,
    profile_picture_url TEXT,
    college_id UUID,
    college_name VARCHAR,
    student_id VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.email,
        u.first_name,
        u.last_name,
        u.role,
        u.is_active,
        u.is_verified,
        u.phone,
        u.profile_picture_url,
        CASE 
            WHEN u.role = 'student' THEN s.college_id
            WHEN u.role = 'tpo' THEN ctm.college_id
            ELSE NULL
        END as college_id,
        CASE 
            WHEN u.role = 'student' THEN c1.name
            WHEN u.role = 'tpo' THEN c2.name
            ELSE NULL
        END as college_name,
        CASE 
            WHEN u.role = 'student' THEN s.student_id
            ELSE NULL
        END as student_id
    FROM users u
    LEFT JOIN students s ON u.id = s.user_id AND u.role = 'student'
    LEFT JOIN colleges c1 ON s.college_id = c1.id
    LEFT JOIN college_tpo_mapping ctm ON u.id = ctm.tpo_id AND u.role = 'tpo'
    LEFT JOIN colleges c2 ON ctm.college_id = c2.id
    WHERE u.email = user_email;
END;
$$ LANGUAGE plpgsql;

-- Create function to log audit events
CREATE OR REPLACE FUNCTION log_audit_event(
    p_user_id UUID,
    p_action audit_action,
    p_entity_type VARCHAR,
    p_entity_id UUID,
    p_old_values JSONB DEFAULT NULL,
    p_new_values JSONB DEFAULT NULL,
    p_description TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    audit_id UUID;
BEGIN
    INSERT INTO audit_logs (
        user_id, 
        action, 
        entity_type, 
        entity_id, 
        old_values, 
        new_values, 
        description
    ) VALUES (
        p_user_id,
        p_action,
        p_entity_type,
        p_entity_id,
        p_old_values,
        p_new_values,
        p_description
    ) RETURNING id INTO audit_id;
    
    RETURN audit_id;
END;
$$ LANGUAGE plpgsql;

-- Create function to get student dashboard stats
CREATE OR REPLACE FUNCTION get_student_dashboard_stats(p_student_id UUID)
RETURNS TABLE (
    total_applications INTEGER,
    pending_applications INTEGER,
    accepted_applications INTEGER,
    rejected_applications INTEGER,
    upcoming_rounds INTEGER,
    unread_notifications INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(a.id)::INTEGER as total_applications,
        COUNT(CASE WHEN a.status = 'pending' THEN 1 END)::INTEGER as pending_applications,
        COUNT(CASE WHEN a.status = 'accepted' THEN 1 END)::INTEGER as accepted_applications,
        COUNT(CASE WHEN a.status = 'rejected' THEN 1 END)::INTEGER as rejected_applications,
        COUNT(DISTINCT CASE WHEN pr.status = 'upcoming' AND prp.student_id = p_student_id THEN pr.id END)::INTEGER as upcoming_rounds,
        COUNT(DISTINCT CASE WHEN n.is_read = FALSE THEN n.id END)::INTEGER as unread_notifications
    FROM students s
    LEFT JOIN applications a ON s.id = a.student_id
    LEFT JOIN placement_round_participants prp ON s.id = prp.student_id
    LEFT JOIN placement_rounds pr ON prp.placement_round_id = pr.id
    LEFT JOIN users u ON s.user_id = u.id
    LEFT JOIN notifications n ON u.id = n.recipient_id AND n.is_read = FALSE
    WHERE s.id = p_student_id;
END;
$$ LANGUAGE plpgsql;

-- Add comments to tables for documentation
COMMENT ON TABLE users IS 'Central user management for all system users';
COMMENT ON TABLE colleges IS 'Institution/college information';
COMMENT ON TABLE students IS 'Student profiles and academic information';
COMMENT ON TABLE companies IS 'Recruiting companies and their details';
COMMENT ON TABLE jobs IS 'Job postings from companies';
COMMENT ON TABLE applications IS 'Student applications to job postings';
COMMENT ON TABLE placement_rounds IS 'Recruitment rounds for job postings';
COMMENT ON TABLE placement_round_participants IS 'Student participation in placement rounds';
COMMENT ON TABLE notifications IS 'System notifications and communications';
COMMENT ON TABLE documents IS 'File storage and document management';
COMMENT ON TABLE audit_logs IS 'Audit trail for all system activities';
COMMENT ON TABLE user_sessions IS 'User session management for authentication';
COMMENT ON TABLE college_tpo_mapping IS 'Association between TPOs and colleges';

-- Schema version tracking
CREATE TABLE schema_version (
    version VARCHAR(20) PRIMARY KEY,
    description TEXT,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO schema_version (version, description) VALUES ('1.0.0', 'Initial CampusConnect schema with comprehensive tables and relationships');
