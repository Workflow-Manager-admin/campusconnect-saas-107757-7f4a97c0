-- Campus Connect SaaS Platform Database Schema
-- Comprehensive schema for campus recruitment management platform
-- Created: 2024

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Drop existing tables if they exist (for development)
DROP TABLE IF EXISTS audit_trails CASCADE;
DROP TABLE IF EXISTS notification_recipients CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS document_uploads CASCADE;
DROP TABLE IF EXISTS analytics_logs CASCADE;
DROP TABLE IF EXISTS placement_status_history CASCADE;
DROP TABLE IF EXISTS placement_rounds CASCADE;
DROP TABLE IF EXISTS job_applications CASCADE;
DROP TABLE IF EXISTS job_postings CASCADE;
DROP TABLE IF EXISTS student_profiles CASCADE;
DROP TABLE IF EXISTS college_admins CASCADE;
DROP TABLE IF EXISTS colleges CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Create ENUM types
CREATE TYPE user_role AS ENUM ('student', 'college_admin', 'tpo', 'super_admin');
CREATE TYPE application_status AS ENUM ('applied', 'shortlisted', 'selected', 'rejected', 'withdrawn');
CREATE TYPE placement_round_type AS ENUM ('written_test', 'technical_interview', 'hr_interview', 'group_discussion', 'presentation', 'final_interview');
CREATE TYPE placement_round_status AS ENUM ('scheduled', 'in_progress', 'completed', 'cancelled');
CREATE TYPE job_status AS ENUM ('draft', 'active', 'closed', 'cancelled');
CREATE TYPE notification_type AS ENUM ('email', 'sms', 'in_app', 'push');
CREATE TYPE notification_status AS ENUM ('pending', 'sent', 'delivered', 'failed');
CREATE TYPE document_type AS ENUM ('resume', 'cover_letter', 'transcript', 'certificate', 'photo', 'id_proof', 'other');
CREATE TYPE analytics_event_type AS ENUM ('login', 'logout', 'job_view', 'job_apply', 'profile_update', 'document_upload', 'placement_round_update');

-- Users table (base table for all user types)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    role user_role NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_by UUID,
    
    CONSTRAINT users_created_by_fk FOREIGN KEY (created_by) REFERENCES users(id),
    CONSTRAINT users_updated_by_fk FOREIGN KEY (updated_by) REFERENCES users(id)
);

-- Colleges table
CREATE TABLE colleges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'India',
    postal_code VARCHAR(20),
    website VARCHAR(255),
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20),
    description TEXT,
    logo_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    subscription_plan VARCHAR(50) DEFAULT 'basic',
    subscription_expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_by UUID,
    
    CONSTRAINT colleges_created_by_fk FOREIGN KEY (created_by) REFERENCES users(id),
    CONSTRAINT colleges_updated_by_fk FOREIGN KEY (updated_by) REFERENCES users(id)
);

-- College admins/TPOs table
CREATE TABLE college_admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    college_id UUID NOT NULL,
    designation VARCHAR(100),
    department VARCHAR(100),
    is_primary BOOLEAN DEFAULT FALSE,
    permissions JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT college_admins_user_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT college_admins_college_fk FOREIGN KEY (college_id) REFERENCES colleges(id) ON DELETE CASCADE,
    CONSTRAINT college_admins_unique UNIQUE (user_id, college_id)
);

-- Student profiles table
CREATE TABLE student_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    college_id UUID NOT NULL,
    student_id VARCHAR(50) NOT NULL,
    branch VARCHAR(100),
    year_of_study INTEGER,
    semester INTEGER,
    current_cgpa DECIMAL(4,2),
    total_cgpa DECIMAL(4,2),
    date_of_birth DATE,
    gender VARCHAR(20),
    category VARCHAR(50),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    linkedin_url VARCHAR(255),
    github_url VARCHAR(255),
    portfolio_url VARCHAR(255),
    skills TEXT[],
    interests TEXT[],
    achievements TEXT[],
    languages TEXT[],
    profile_photo_url VARCHAR(500),
    resume_url VARCHAR(500),
    is_placement_eligible BOOLEAN DEFAULT TRUE,
    placement_status VARCHAR(50) DEFAULT 'available',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT student_profiles_user_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT student_profiles_college_fk FOREIGN KEY (college_id) REFERENCES colleges(id) ON DELETE CASCADE,
    CONSTRAINT student_profiles_unique UNIQUE (user_id),
    CONSTRAINT student_profiles_college_student_unique UNIQUE (college_id, student_id)
);

-- Job postings table
CREATE TABLE job_postings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    college_id UUID NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    job_title VARCHAR(255) NOT NULL,
    job_description TEXT NOT NULL,
    job_type VARCHAR(50) DEFAULT 'full_time',
    location VARCHAR(255),
    salary_min DECIMAL(12,2),
    salary_max DECIMAL(12,2),
    currency VARCHAR(10) DEFAULT 'INR',
    required_skills TEXT[],
    preferred_skills TEXT[],
    experience_required VARCHAR(100),
    education_requirements TEXT,
    eligibility_criteria TEXT,
    application_deadline TIMESTAMP WITH TIME ZONE,
    interview_process TEXT,
    company_description TEXT,
    company_website VARCHAR(255),
    company_logo_url VARCHAR(500),
    contact_person_name VARCHAR(100),
    contact_person_email VARCHAR(255),
    contact_person_phone VARCHAR(20),
    min_cgpa DECIMAL(4,2),
    allowed_branches TEXT[],
    allowed_years INTEGER[],
    max_applications INTEGER,
    status job_status DEFAULT 'draft',
    is_featured BOOLEAN DEFAULT FALSE,
    views_count INTEGER DEFAULT 0,
    applications_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_by UUID,
    
    CONSTRAINT job_postings_college_fk FOREIGN KEY (college_id) REFERENCES colleges(id) ON DELETE CASCADE,
    CONSTRAINT job_postings_created_by_fk FOREIGN KEY (created_by) REFERENCES users(id),
    CONSTRAINT job_postings_updated_by_fk FOREIGN KEY (updated_by) REFERENCES users(id)
);

-- Job applications table
CREATE TABLE job_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID NOT NULL,
    student_id UUID NOT NULL,
    cover_letter TEXT,
    custom_resume_url VARCHAR(500),
    application_data JSONB DEFAULT '{}',
    status application_status DEFAULT 'applied',
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status_updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status_updated_by UUID,
    notes TEXT,
    score DECIMAL(5,2),
    feedback TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT job_applications_job_fk FOREIGN KEY (job_id) REFERENCES job_postings(id) ON DELETE CASCADE,
    CONSTRAINT job_applications_student_fk FOREIGN KEY (student_id) REFERENCES student_profiles(id) ON DELETE CASCADE,
    CONSTRAINT job_applications_status_updated_by_fk FOREIGN KEY (status_updated_by) REFERENCES users(id),
    CONSTRAINT job_applications_unique UNIQUE (job_id, student_id)
);

-- Placement rounds table
CREATE TABLE placement_rounds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID NOT NULL,
    round_number INTEGER NOT NULL,
    round_name VARCHAR(100) NOT NULL,
    round_type placement_round_type NOT NULL,
    description TEXT,
    scheduled_at TIMESTAMP WITH TIME ZONE,
    duration_minutes INTEGER,
    location VARCHAR(255),
    meeting_link VARCHAR(500),
    instructions TEXT,
    status placement_round_status DEFAULT 'scheduled',
    max_participants INTEGER,
    current_participants INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_by UUID,
    
    CONSTRAINT placement_rounds_job_fk FOREIGN KEY (job_id) REFERENCES job_postings(id) ON DELETE CASCADE,
    CONSTRAINT placement_rounds_created_by_fk FOREIGN KEY (created_by) REFERENCES users(id),
    CONSTRAINT placement_rounds_updated_by_fk FOREIGN KEY (updated_by) REFERENCES users(id),
    CONSTRAINT placement_rounds_unique UNIQUE (job_id, round_number)
);

-- Placement status history table
CREATE TABLE placement_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id UUID NOT NULL,
    round_id UUID,
    previous_status application_status,
    new_status application_status NOT NULL,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    changed_by UUID,
    reason TEXT,
    notes TEXT,
    score DECIMAL(5,2),
    feedback TEXT,
    
    CONSTRAINT placement_status_history_application_fk FOREIGN KEY (application_id) REFERENCES job_applications(id) ON DELETE CASCADE,
    CONSTRAINT placement_status_history_round_fk FOREIGN KEY (round_id) REFERENCES placement_rounds(id) ON DELETE SET NULL,
    CONSTRAINT placement_status_history_changed_by_fk FOREIGN KEY (changed_by) REFERENCES users(id)
);

-- Analytics logs table
CREATE TABLE analytics_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID,
    college_id UUID,
    event_type analytics_event_type NOT NULL,
    event_data JSONB DEFAULT '{}',
    ip_address INET,
    user_agent TEXT,
    session_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT analytics_logs_user_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT analytics_logs_college_fk FOREIGN KEY (college_id) REFERENCES colleges(id) ON DELETE SET NULL
);

-- Notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    college_id UUID,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type notification_type NOT NULL,
    template_id VARCHAR(100),
    template_data JSONB DEFAULT '{}',
    target_roles user_role[],
    target_users UUID[],
    target_criteria JSONB DEFAULT '{}',
    scheduled_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    priority INTEGER DEFAULT 1,
    status notification_status DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    
    CONSTRAINT notifications_college_fk FOREIGN KEY (college_id) REFERENCES colleges(id) ON DELETE CASCADE,
    CONSTRAINT notifications_created_by_fk FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Notification recipients table
CREATE TABLE notification_recipients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    notification_id UUID NOT NULL,
    user_id UUID NOT NULL,
    status notification_status DEFAULT 'pending',
    sent_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    read_at TIMESTAMP WITH TIME ZONE,
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT notification_recipients_notification_fk FOREIGN KEY (notification_id) REFERENCES notifications(id) ON DELETE CASCADE,
    CONSTRAINT notification_recipients_user_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT notification_recipients_unique UNIQUE (notification_id, user_id)
);

-- Document uploads table
CREATE TABLE document_uploads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    college_id UUID,
    entity_type VARCHAR(50) NOT NULL, -- 'user', 'job_application', 'college', etc.
    entity_id UUID,
    document_type document_type NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size INTEGER,
    mime_type VARCHAR(100),
    file_hash VARCHAR(255),
    is_public BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    verified_by UUID,
    verified_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT document_uploads_user_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT document_uploads_college_fk FOREIGN KEY (college_id) REFERENCES colleges(id) ON DELETE CASCADE,
    CONSTRAINT document_uploads_verified_by_fk FOREIGN KEY (verified_by) REFERENCES users(id)
);

-- Audit trails table
CREATE TABLE audit_trails (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID,
    college_id UUID,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID,
    action VARCHAR(50) NOT NULL,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    session_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT audit_trails_user_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT audit_trails_college_fk FOREIGN KEY (college_id) REFERENCES colleges(id) ON DELETE SET NULL
);

-- Create indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_created_at ON users(created_at);

CREATE INDEX idx_colleges_code ON colleges(code);
CREATE INDEX idx_colleges_is_active ON colleges(is_active);
CREATE INDEX idx_colleges_created_at ON colleges(created_at);

CREATE INDEX idx_college_admins_user_id ON college_admins(user_id);
CREATE INDEX idx_college_admins_college_id ON college_admins(college_id);

CREATE INDEX idx_student_profiles_user_id ON student_profiles(user_id);
CREATE INDEX idx_student_profiles_college_id ON student_profiles(college_id);
CREATE INDEX idx_student_profiles_student_id ON student_profiles(student_id);
CREATE INDEX idx_student_profiles_branch ON student_profiles(branch);
CREATE INDEX idx_student_profiles_year_of_study ON student_profiles(year_of_study);
CREATE INDEX idx_student_profiles_placement_eligible ON student_profiles(is_placement_eligible);

CREATE INDEX idx_job_postings_college_id ON job_postings(college_id);
CREATE INDEX idx_job_postings_status ON job_postings(status);
CREATE INDEX idx_job_postings_application_deadline ON job_postings(application_deadline);
CREATE INDEX idx_job_postings_created_at ON job_postings(created_at);
CREATE INDEX idx_job_postings_company_name ON job_postings(company_name);
CREATE INDEX idx_job_postings_job_title ON job_postings(job_title);

CREATE INDEX idx_job_applications_job_id ON job_applications(job_id);
CREATE INDEX idx_job_applications_student_id ON job_applications(student_id);
CREATE INDEX idx_job_applications_status ON job_applications(status);
CREATE INDEX idx_job_applications_applied_at ON job_applications(applied_at);

CREATE INDEX idx_placement_rounds_job_id ON placement_rounds(job_id);
CREATE INDEX idx_placement_rounds_scheduled_at ON placement_rounds(scheduled_at);
CREATE INDEX idx_placement_rounds_status ON placement_rounds(status);

CREATE INDEX idx_placement_status_history_application_id ON placement_status_history(application_id);
CREATE INDEX idx_placement_status_history_round_id ON placement_status_history(round_id);
CREATE INDEX idx_placement_status_history_changed_at ON placement_status_history(changed_at);

CREATE INDEX idx_analytics_logs_user_id ON analytics_logs(user_id);
CREATE INDEX idx_analytics_logs_college_id ON analytics_logs(college_id);
CREATE INDEX idx_analytics_logs_event_type ON analytics_logs(event_type);
CREATE INDEX idx_analytics_logs_created_at ON analytics_logs(created_at);

CREATE INDEX idx_notifications_college_id ON notifications(college_id);
CREATE INDEX idx_notifications_status ON notifications(status);
CREATE INDEX idx_notifications_scheduled_at ON notifications(scheduled_at);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

CREATE INDEX idx_notification_recipients_notification_id ON notification_recipients(notification_id);
CREATE INDEX idx_notification_recipients_user_id ON notification_recipients(user_id);
CREATE INDEX idx_notification_recipients_status ON notification_recipients(status);

CREATE INDEX idx_document_uploads_user_id ON document_uploads(user_id);
CREATE INDEX idx_document_uploads_college_id ON document_uploads(college_id);
CREATE INDEX idx_document_uploads_entity_type ON document_uploads(entity_type);
CREATE INDEX idx_document_uploads_entity_id ON document_uploads(entity_id);
CREATE INDEX idx_document_uploads_document_type ON document_uploads(document_type);

CREATE INDEX idx_audit_trails_user_id ON audit_trails(user_id);
CREATE INDEX idx_audit_trails_college_id ON audit_trails(college_id);
CREATE INDEX idx_audit_trails_entity_type ON audit_trails(entity_type);
CREATE INDEX idx_audit_trails_entity_id ON audit_trails(entity_id);
CREATE INDEX idx_audit_trails_action ON audit_trails(action);
CREATE INDEX idx_audit_trails_created_at ON audit_trails(created_at);

-- Create triggers for updated_at columns
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_colleges_updated_at BEFORE UPDATE ON colleges
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_college_admins_updated_at BEFORE UPDATE ON college_admins
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_student_profiles_updated_at BEFORE UPDATE ON student_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_job_postings_updated_at BEFORE UPDATE ON job_postings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_job_applications_updated_at BEFORE UPDATE ON job_applications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_placement_rounds_updated_at BEFORE UPDATE ON placement_rounds
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notification_recipients_updated_at BEFORE UPDATE ON notification_recipients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_document_uploads_updated_at BEFORE UPDATE ON document_uploads
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create views for common queries
CREATE VIEW active_jobs AS
SELECT 
    jp.*,
    c.name as college_name,
    c.code as college_code,
    COUNT(ja.id) as total_applications
FROM job_postings jp
JOIN colleges c ON jp.college_id = c.id
LEFT JOIN job_applications ja ON jp.id = ja.job_id
WHERE jp.status = 'active' 
    AND jp.application_deadline > CURRENT_TIMESTAMP
    AND c.is_active = TRUE
GROUP BY jp.id, c.name, c.code;

CREATE VIEW student_dashboard AS
SELECT 
    sp.*,
    u.email,
    u.first_name,
    u.last_name,
    u.phone,
    u.last_login,
    c.name as college_name,
    c.code as college_code,
    COUNT(ja.id) as total_applications,
    COUNT(CASE WHEN ja.status = 'selected' THEN 1 END) as selected_applications
FROM student_profiles sp
JOIN users u ON sp.user_id = u.id
JOIN colleges c ON sp.college_id = c.id
LEFT JOIN job_applications ja ON sp.id = ja.student_id
WHERE u.is_active = TRUE
GROUP BY sp.id, u.email, u.first_name, u.last_name, u.phone, u.last_login, c.name, c.code;

CREATE VIEW placement_statistics AS
SELECT 
    c.id as college_id,
    c.name as college_name,
    COUNT(DISTINCT sp.id) as total_students,
    COUNT(DISTINCT ja.id) as total_applications,
    COUNT(DISTINCT CASE WHEN ja.status = 'selected' THEN ja.id END) as selected_applications,
    COUNT(DISTINCT jp.id) as total_jobs,
    COUNT(DISTINCT jp.company_name) as total_companies,
    ROUND(AVG(jp.salary_max), 2) as avg_max_salary,
    ROUND(AVG(jp.salary_min), 2) as avg_min_salary
FROM colleges c
LEFT JOIN student_profiles sp ON c.id = sp.college_id
LEFT JOIN job_postings jp ON c.id = jp.college_id
LEFT JOIN job_applications ja ON jp.id = ja.job_id
WHERE c.is_active = TRUE
GROUP BY c.id, c.name;

-- Add comments for documentation
COMMENT ON TABLE users IS 'Base table for all user types including students, TPOs, and admins';
COMMENT ON TABLE colleges IS 'College/institution information and subscription details';
COMMENT ON TABLE college_admins IS 'TPO and admin users linked to colleges';
COMMENT ON TABLE student_profiles IS 'Detailed student information and academic records';
COMMENT ON TABLE job_postings IS 'Job opportunities posted by companies';
COMMENT ON TABLE job_applications IS 'Student applications to job postings';
COMMENT ON TABLE placement_rounds IS 'Interview rounds and placement process stages';
COMMENT ON TABLE placement_status_history IS 'Audit trail of application status changes';
COMMENT ON TABLE analytics_logs IS 'User activity and system usage tracking';
COMMENT ON TABLE notifications IS 'System notifications and communications';
COMMENT ON TABLE notification_recipients IS 'Individual notification delivery tracking';
COMMENT ON TABLE document_uploads IS 'File uploads and document management';
COMMENT ON TABLE audit_trails IS 'Complete audit trail for all system changes';

-- Grant permissions (assuming the user from startup.sh)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO appuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO appuser;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO appuser;
