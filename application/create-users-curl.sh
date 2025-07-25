# TalentPivot User Creation via cURL
# =================================

echo "Creating Users with cURL Commands"
echo "================================="
echo ""

echo "1. Creating HR User..."
curl -X POST https://talentpivot-backend-z7qlsmuifa-uc.a.run.app/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Jennifer Admin",
    "email": "jennifer@talentpivot.com", 
    "phone": "5551112222",
    "password": "AdminPass123!",
    "role": "HR"
  }'

echo ""
echo ""

echo "2. Creating Candidate User..."
curl -X POST https://talentpivot-backend-z7qlsmuifa-uc.a.run.app/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "David Developer",
    "email": "david@email.com",
    "phone": "5553334444", 
    "experience": 5,
    "band": "Senior",
    "skill": "JavaScript, React, Node.js, MongoDB",
    "password": "DevPass123!",
    "role": "candidate"
  }'

echo ""
echo ""
echo "Users created! They can login at:"
echo "https://talentpivot-frontend-z7qlsmuifa-uc.a.run.app"
