# Campus Connect SaaS Platform - Database Schema Documentation

## Overview

This directory contains the PostgreSQL database schema and seed data for the Campus Connect SaaS platform - a comprehensive campus recruitment management system designed for colleges, TPOs, and students.

## Database Structure

### Core Entities

#### 1. **Users** (`users`)
- Base table for all user types (students, TPOs, college admins, super admins)
- Stores authentication details, basic profile information, and role assignments
- Uses bcrypt password hashing for security

#### 2. **Colleges** (`colleges`)
- Institution information and subscription management
- Supports multi-tenancy with college-specific data isolation
- Tracks subscription plans and expiration dates

#### 3. **Student Profiles** (`student_profiles`)
- Detailed student information linked to users and colleges
- Academic records, skills, achievements, and placement eligibility
- Portfolio links and document references

#### 4. **Job Postings** (`job_postings`)
- Company job opportunities with detailed requirements
- Eligibility criteria filtering (CGPA, branches, years)
- Application tracking and status management

#### 5. **Job Applications** (`job_applications`)
- Student applications to job postings
- Status tracking through placement pipeline
- Feedback and scoring system

#### 6. **Placement Rounds** (`placement_rounds`)
- Multi-stage interview process management
- Scheduling and participant tracking
- Support for various round types (written, technical, HR, etc.)

#### 7. **Notifications** (`notifications`, `notification_recipients`)
- Bulk communication system for emails, SMS, and in-app notifications
- Role-based and criteria-based targeting
- Delivery tracking and status monitoring

#### 8. **Document Management** (`document_uploads`)
- File upload and storage tracking
- Document verification workflow
- Support for resumes, certificates, photos, etc.

#### 9. **Analytics & Audit** (`analytics_logs`, `audit_trails`)
- User activity tracking and system usage metrics
- Complete audit trail for all data changes
- Security and compliance monitoring

### Key Features

- **Role-Based Access Control**: Four distinct user roles with appropriate permissions
- **Multi-Tenancy**: College-specific data isolation and management
- **Audit Trail**: Complete tracking of all system changes
- **Notification System**: Bulk communication with delivery tracking
- **Document Management**: Secure file handling with verification
- **Analytics**: User activity and system usage tracking
- **Placement Pipeline**: Multi-stage interview process management

## Database Connection

### Environment Variables
The following environment variables are available for database connection:

```bash
POSTGRES_URL="postgresql://localhost:5000/myapp"
POSTGRES_USER="appuser"
POSTGRES_PASSWORD="dbuser123"
POSTGRES_DB="myapp"
POSTGRES_PORT="5000"
```

### Connection String
```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp
```

## Schema Setup

### 1. Initialize Database
```bash
# Run the main schema creation
psql postgresql://appuser:dbuser123@localhost:5000/myapp -f schema.sql
```

### 2. Load Sample Data
```bash
# Load seed data for development/testing
psql postgresql://appuser:dbuser123@localhost:5000/myapp -f seed_data.sql
```

### 3. Verify Setup
```sql
-- Check if all tables are created
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- Verify sample data
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM colleges;
SELECT COUNT(*) FROM job_postings;
```

## API Integration Notes for Backend Developers

### Authentication & Users

#### User Registration
```sql
-- Create new user
INSERT INTO users (email, password_hash, first_name, last_name, role, created_by)
VALUES ($1, crypt($2, gen_salt('bf')), $3, $4, $5, $6);
```

#### User Login
```sql
-- Authenticate user
SELECT id, email, first_name, last_name, role, is_active, last_login
FROM users 
WHERE email = $1 AND password_hash = crypt($2, password_hash) AND is_active = true;
```

#### Role-Based Queries
```sql
-- Get TPO users for a college
SELECT u.*, ca.designation, ca.permissions
FROM users u
JOIN college_admins ca ON u.id = ca.user_id
WHERE ca.college_id = $1 AND u.role IN ('tpo', 'college_admin');

-- Get students for a college
SELECT u.*, sp.student_id, sp.branch, sp.year_of_study, sp.current_cgpa
FROM users u
JOIN student_profiles sp ON u.id = sp.user_id
WHERE sp.college_id = $1 AND u.role = 'student';
```

### Job Management

#### Active Jobs Query
```sql
-- Get active job postings with application counts
SELECT * FROM active_jobs WHERE college_id = $1 ORDER BY created_at DESC;
```

#### Job Application
```sql
-- Submit job application
INSERT INTO job_applications (job_id, student_id, cover_letter, status)
VALUES ($1, $2, $3, 'applied');

-- Update application count
UPDATE job_postings SET applications_count = applications_count + 1 WHERE id = $1;
```

#### Application Status Updates
```sql
-- Update application status with history
BEGIN;
UPDATE job_applications SET status = $2, status_updated_at = NOW(), status_updated_by = $3 WHERE id = $1;
INSERT INTO placement_status_history (application_id, previous_status, new_status, changed_by, reason)
VALUES ($1, $4, $2, $3, $5);
COMMIT;
```

### Analytics & Reporting

#### Student Dashboard Data
```sql
-- Get comprehensive student dashboard data
SELECT * FROM student_dashboard WHERE user_id = $1;
```

#### Placement Statistics
```sql
-- Get college placement statistics
SELECT * FROM placement_statistics WHERE college_id = $1;
```

#### Activity Logging
```sql
-- Log user activity
INSERT INTO analytics_logs (user_id, college_id, event_type, event_data, ip_address, session_id)
VALUES ($1, $2, $3, $4, $5, $6);
```

### Notifications

#### Bulk Notifications
```sql
-- Create notification for multiple users
INSERT INTO notifications (college_id, title, message, type, target_roles, created_by)
VALUES ($1, $2, $3, $4, $5, $6);

-- Add recipients based on criteria
INSERT INTO notification_recipients (notification_id, user_id)
SELECT $1, u.id FROM users u 
JOIN student_profiles sp ON u.id = sp.user_id
WHERE sp.college_id = $2 AND u.role = ANY($3);
```

### Document Management

#### File Upload Tracking
```sql
-- Track document upload
INSERT INTO document_uploads (user_id, college_id, entity_type, entity_id, document_type, file_name, file_path, file_size, mime_type)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9);
```

### Audit Trail

#### Change Tracking
```sql
-- Log data changes
INSERT INTO audit_trails (user_id, college_id, entity_type, entity_id, action, old_values, new_values, ip_address, session_id)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9);
```

## Performance Considerations

### Indexing Strategy
- All foreign keys are indexed for join performance
- Composite indexes on commonly queried columns
- Partial indexes on status fields for active records

### Query Optimization
- Use prepared statements for repeated queries
- Leverage the pre-built views for common dashboard queries
- Implement pagination for large result sets
- Use EXPLAIN ANALYZE for query performance analysis

### Connection Pooling
- Configure connection pooling in your application
- Recommended pool size: 10-20 connections per instance
- Monitor connection usage and adjust as needed

## Security Best Practices

### Data Protection
- All passwords are bcrypt hashed
- Use parameterized queries to prevent SQL injection
- Implement row-level security for multi-tenant data

### Access Control
- Validate user roles before data access
- Use college_id filtering for data isolation
- Implement proper session management

### Audit Compliance
- All data modifications are logged in audit_trails
- User activities are tracked in analytics_logs
- Document access and modifications are recorded

## Sample Data

The seed data includes:
- 1 Super Admin
- 3 Colleges (IIT Delhi, NIT Trichy, BITS Pilani)
- 3 TPO users (one per college)
- 6 Student users with detailed profiles
- 5 Job postings from major companies
- Sample applications and placement rounds
- Notification and document examples

## Maintenance

### Regular Tasks
- Monitor database size and performance
- Clean up old analytics logs (consider partitioning)
- Archive completed placement records
- Update statistics for query optimization

### Backup Strategy
- Daily full backups
- Transaction log backups every 15 minutes
- Test restore procedures regularly

### Monitoring
- Track query performance and slow queries
- Monitor connection usage and pool health
- Set up alerts for error conditions

## Troubleshooting

### Common Issues

1. **Connection Refused**
   - Check if PostgreSQL is running on port 5000
   - Verify firewall settings
   - Check connection string format

2. **Permission Denied**
   - Verify user permissions on database
   - Check if user has CREATE privileges on public schema
   - Ensure proper role assignments

3. **Schema Not Found**
   - Run schema.sql to create all tables
   - Check if extensions are installed
   - Verify database name in connection string

### Performance Issues
- Check for missing indexes on frequently queried columns
- Analyze query execution plans
- Consider query optimization or schema adjustments

## Development Workflow

1. **Local Development**
   - Use docker-compose for local PostgreSQL instance
   - Run migrations to keep schema in sync
   - Use seed data for testing

2. **Testing**
   - Create separate test database
   - Use transactions for test isolation
   - Reset data between test runs

3. **Production Deployment**
   - Use migration scripts for schema changes
   - Backup before any schema modifications
   - Monitor performance after deployments

## Contact & Support

For database-related questions or issues:
- Check the audit_trails table for recent changes
- Review analytics_logs for user activity patterns
- Use the pre-built views for common queries
- Refer to PostgreSQL documentation for advanced features

---

*This documentation is maintained alongside the database schema. Update this file when making schema changes.*
