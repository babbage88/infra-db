-- +goose Up
CREATE OR REPLACE VIEW role_permission_counts AS
SELECT 
  r.id, 
  r.role_name, 
  COUNT(rpm.permission_id) as permission_count
FROM user_roles r
LEFT JOIN role_permission_mapping rpm
  ON r.id = rpm.role_id
 AND rpm.enabled = TRUE
WHERE r.is_deleted = FALSE
GROUP BY r.id, r.role_name;

-- +goose Down
DROP VIEW IF EXISTS role_permission_counts;
