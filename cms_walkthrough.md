# GitHub CMS Walkthrough

## Overview

This project uses **GitHub as a Content Management System (CMS)** to store and manage all dynamic content. Instead of using traditional databases or CMS platforms, we leverage GitHub's repository as a data store with JSON files, making content versioned, transparent, and fully integrated with the deployment workflow.

## How GitHub CMS Works

### Core Concept

1. **Data Storage**: All dynamic content is stored as JSON files in `assets/data/` directory
2. **Version Control**: Every change is a git commit, providing full audit trail
3. **API Access**: GitHub Contents API allows reading/writing files programmatically
4. **CI/CD Integration**: Changes trigger automatic rebuilds via GitHub Actions
5. **Authentication**: Personal Access Token (PAT) for secure API access

### Data Structure

```
assets/data/
├── blogs.json          # Blog posts with wrapper: {"blogs": [...]}
├── profile.json        # Personal profile (single object)
├── skills.json         # Skills data (single object)
├── projects.json       # Projects with wrapper: {"projects": [...]}
├── experience.json     # Work experience with wrapper: {"experiences": [...]}
├── certifications.json # Certifications with wrapper: {"certifications": [...]}
└── testimonials.json   # Testimonials with wrapper: {"testimonials": [...]}
```

### GitHub Contents API Flow

#### Reading Data
```
GET https://api.github.com/repos/{owner}/{repo}/contents/assets/data/{filename}
Authorization: Bearer {PAT}

Response:
{
  "name": "blogs.json",
  "path": "assets/data/blogs.json",
  "sha": "abc123...",  // File version hash (required for updates)
  "content": "base64-encoded-json",
  "encoding": "base64"
}
```

#### Writing Data
```
PUT https://api.github.com/repos/{owner}/{repo}/contents/assets/data/{filename}
Authorization: Bearer {PAT}

Body:
{
  "message": "cms: update blogs",
  "content": "base64-encoded-json",
  "sha": "abc123..."  // Previous SHA (prevents overwrite conflicts)
}
```

## Project Integration - Step by Step

### Step 1: GitHub Service Layer

**File**: `lib/core/services/github_cms_service.dart`

This service handles all GitHub API interactions:

```dart
class GitHubCmsService {
  final String owner;     // GitHub username
  final String repo;      // Repository name
  final String token;     // Personal Access Token
  
  // Base configuration
  final baseUrl = 'https://api.github.com/repos/$owner/$repo/contents/assets/data';
}
```

**Key Methods**:

1. **`_getFile(String filename)`**: Fetches file from GitHub
   - Makes GET request to Contents API
   - Decodes base64 content
   - Returns content + SHA hash

2. **`_putFile(...)`**: Writes file to GitHub
   - Encodes JSON to base64
   - Makes PUT request with SHA for version control
   - Creates git commit with custom message

3. **Entity-specific methods**:
   ```dart
   // Blogs (wrapper structure)
   Future<({List<dynamic> blogs, String sha})> getBlogs()
   Future<void> saveBlogs({String sha, List blogs, String commitMessage})
   
   // Projects (wrapper structure)
   Future<({List<dynamic> projects, String sha})> getProjectsWrapped()
   Future<void> saveProjectsWrapped({...})
   
   // Profile (single object)
   Future<({Map<String, dynamic> profile, String sha})> getProfile()
   Future<void> saveProfile({...})
   
   // Similar methods for: skills, experience, certifications, testimonials
   ```

### Step 2: State Management with Riverpod

**File**: `lib/core/providers/github_settings_provider.dart`

```dart
// Stores GitHub configuration in SharedPreferences
final githubSettingsProvider = StateNotifierProvider<GitHubSettingsNotifier, GitHubSettings>

// Provides GitHubCmsService instance (null if not configured)
final githubCmsServiceProvider = Provider<GitHubCmsService?>((ref) {
  final settings = ref.watch(githubSettingsProvider);
  if (settings.owner.isEmpty || settings.repo.isEmpty || settings.token.isEmpty) {
    return null;
  }
  return GitHubCmsService(
    owner: settings.owner,
    repo: settings.repo,
    token: settings.token,
  );
});
```

### Step 3: Admin Dashboard Architecture

**Files**: 
- `lib/features/admin/presentation/pages/admin_dashboard_page.dart` (main dashboard)
- `lib/features/admin/presentation/pages/admin_content_tabs.dart` (CRUD tabs)
- `lib/features/admin/presentation/widgets/cms_tab_scaffold.dart` (reusable UI)
- `lib/features/admin/presentation/widgets/cms_state_mixin.dart` (shared logic)

**Dashboard Structure**:
```
AdminDashboard
├── Sidebar Navigation (9 tabs)
├── Overview Tab (stats, charts, quick actions)
├── Profile Tab (personal info CRUD)
├── Skills Tab (skills CRUD)
├── Experience Tab (work experience CRUD)
├── Projects Tab (project portfolio CRUD)
├── Blog Tab (blog post CRUD)
├── Certifications Tab (certifications CRUD)
├── Testimonials Tab (testimonials CRUD)
└── Settings Tab (GitHub config, theme)
```

### Step 4: Reusable CMS Components

**CmsTabScaffold Widget** (`cms_tab_scaffold.dart`):
```dart
CmsTabScaffold(
  title: 'Blog Posts',
  body: ListView(...),
  actions: [SaveButton(), AddButton()],
  statusMsg: 'Saved successfully!',
  isSaving: false,
  needsConfig: cmsService == null,
)
```

**CmsStateMixin** (`cms_state_mixin.dart`):
```dart
mixin CmsStateMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool saving = false;
  String statusMsg = '';
  bool isError = false;
  
  // Wrapper for CMS operations with loading states
  Future<void> cmsOp(Future<void> Function() fn) async {
    setState(() => saving = true);
    try {
      await fn();
      showStatus('Saved successfully!');
    } catch (e) {
      showStatus('Error: $e', isError: true);
    } finally {
      setState(() => saving = false);
    }
  }
}
```

### Step 5: CRUD Operations Pattern

**Example: Blog Post Management** (`admin_dashboard_page.dart`)

#### Create/Update Flow:
```dart
Future<void> _openEditDialog([Map<String, dynamic>? blog]) async {
  // 1. Show form dialog
  final result = await showDialog(...);
  if (result == null) return;
  
  // 2. Wrap in cmsOp for error handling
  await cmsOp(() async {
    final cmsService = ref.read(githubCmsServiceProvider)!;
    
    // 3. Fetch current data + SHA
    final data = await cmsService.getBlogs();
    final blogs = (data.blogs as List).cast<Map<String, dynamic>>().map((b) => {
      ...b,
      'tags': (b['tags'] as List?)?.cast<String>() ?? <String>[]
    }).toList();
    
    // 4. Add or update blog
    if (blog == null) {
      blogs.insert(0, result);  // New blog at top
    } else {
      final index = blogs.indexWhere((b) => b['id'] == blog['id']);
      blogs[index] = result;
    }
    
    // 5. Save back to GitHub (triggers rebuild)
    await cmsService.saveBlogs(
      sha: data.sha,
      blogs: blogs,
      commitMessage: 'cms: ${blog == null ? 'add' : 'update'} blog ${result['title']}',
    );
  });
}
```

#### Delete Flow:
```dart
Future<void> _deleteBlog(String id) async {
  await cmsOp(() async {
    final data = await cmsService!.getBlogs();
    final blogs = (data.blogs as List).cast<Map<String, dynamic>>()
      .where((b) => b['id'] != id)
      .toList();
    
    await cmsService!.saveBlogs(
      sha: data.sha,
      blogs: blogs,
      commitMessage: 'cms: delete blog $id',
    );
  });
}
```

### Step 6: JSON Structure Handling

**Two Structure Types**:

1. **Wrapper Structure** (blogs, projects, experience, etc.):
```json
{
  "blogs": [
    {
      "id": "post-1",
      "title": "My Post",
      "tags": ["flutter", "dart"]
    }
  ]
}
```

2. **Direct Object** (profile, skills):
```json
{
  "name": "John Doe",
  "bio": "Developer",
  "skills": {
    "technical": [...]
  }
}
```

**Type Safety**:
```dart
// Always cast nested lists explicitly
final blogs = (data.blogs as List).cast<Map<String, dynamic>>().map((b) => {
  ...b,
  'tags': (b['tags'] as List?)?.cast<String>() ?? <String>[]
}).toList();
```

### Step 7: Authentication & Configuration

**Settings Tab** (`admin_dashboard_page.dart`):

1. **GitHub PAT Configuration**:
```dart
TextField(
  decoration: InputDecoration(labelText: 'Personal Access Token'),
  obscureText: true,
)

ElevatedButton(
  onPressed: _validateAndSaveGitHubSettings,
  child: Text('Validate & Save'),
)
```

2. **Token Validation**:
```dart
Future<void> _validateAndSaveGitHubSettings() async {
  final service = GitHubCmsService(owner: owner, repo: repo, token: token);
  final isValid = await service.validateToken();
  
  if (isValid) {
    // Save to SharedPreferences
    await ref.read(githubSettingsProvider.notifier).setGitHub(owner, repo, token);
  }
}
```

3. **PAT Permissions Required**:
   - `repo` scope (full repository access)
   - Or `public_repo` scope (for public repositories)

### Step 8: CI/CD Integration

**File**: `.github/workflows/deploy.yml`

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  deploy:
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.41.1'
      
      - run: flutter test --no-pub
      
      - run: flutter build web --release --base-href "/Portfolio/"
      
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

**Workflow**:
1. Admin edits content in admin panel
2. `saveBlogs(...)` commits JSON file to GitHub
3. GitHub Actions detects push to main branch
4. Runs tests and builds Flutter web app (~2 minutes)
5. Deploys to GitHub Pages
6. New content is live!

## Usage Guide

### For Admins

1. **Initial Setup**:
   - Navigate to admin panel: `/admin`
   - Login (username: `admin`, password: `admin123`)
   - Go to Settings tab
   - Enter GitHub username, repository name, and Personal Access Token
   - Click "Validate & Save"

2. **Creating GitHub PAT**:
   - Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Click "Generate new token (classic)"
   - Select `repo` scope
   - Copy token and paste in Settings tab

3. **Managing Content**:
   - Use sidebar to navigate to any content section
   - Click "Add" to create new entries
   - Click edit icon to modify existing entries
   - Click delete icon to remove entries
   - Changes commit immediately to GitHub
   - Wait ~2 minutes for deployment

4. **Monitoring**:
   - Overview tab shows content statistics
   - Bar chart displays visitor analytics
   - Quick action buttons for common tasks

### For Developers

1. **Local Testing**:
```bash
# Run app in debug mode
flutter run -d chrome

# Access admin panel
# Navigate to /admin
# Configure GitHub settings in Settings tab
```

2. **Adding New Entity Types**:

Step 1: Add methods to `GitHubCmsService`:
```dart
Future<({List<dynamic> items, String sha})> getNewEntity() async {
  final file = await _getFile('new_entity.json');
  final data = jsonDecode(file.content) as Map<String, dynamic>;
  return (items: data['items'] as List, sha: file.sha);
}

Future<void> saveNewEntity({required String sha, required List items}) async {
  await _putFile(
    filename: 'new_entity.json',
    sha: sha,
    json: {'items': items},
    commitMessage: 'cms: update new entity',
  );
}
```

Step 2: Create admin tab widget in `admin_content_tabs.dart`:
```dart
class NewEntityAdminTab extends ConsumerStatefulWidget {
  const NewEntityAdminTab({super.key});
  
  @override
  ConsumerState<NewEntityAdminTab> createState() => _NewEntityAdminTabState();
}

class _NewEntityAdminTabState extends ConsumerState<NewEntityAdminTab> 
    with CmsStateMixin {
  // Implement CRUD operations using cmsOp() wrapper
}
```

Step 3: Add tab to `AdminDashboardPage` sidebar.

3. **Error Handling**:
```dart
// All CMS operations should use cmsOp wrapper
await cmsOp(() async {
  // Your GitHub CMS operations here
  // Errors are caught and displayed automatically
});
```

## Architecture Benefits

### ✅ Advantages

1. **Version Control**: Every change is tracked in git history
2. **Cost**: Free for public repositories
3. **Transparency**: All data visible in repository
4. **Backup**: Git provides automatic backup
5. **CI/CD Integration**: Changes trigger automatic rebuilds
6. **No Database**: No need for separate database hosting
7. **Developer Friendly**: JSON files are easy to work with
8. **Audit Trail**: Full commit history for compliance

### ⚠️ Considerations

1. **Rate Limits**: GitHub API has rate limits (5000 requests/hour authenticated)
2. **Latency**: API calls take ~500ms-1s
3. **Concurrent Edits**: SHA-based locking prevents conflicts but doesn't queue changes
4. **Build Time**: Content changes require ~2 minute rebuild
5. **File Size**: Keep JSON files reasonable (<1MB recommended)

## Security Best Practices

1. **PAT Storage**: 
   - Stored in `SharedPreferences` (browser localStorage)
   - Never commit PAT to repository
   - Use minimum required scopes

2. **Admin Authentication**:
   - Password hash stored: `8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918`
   - Session stored in SharedPreferences
   - Change default password in production!

3. **CORS & Origins**:
   - GitHub API allows cross-origin requests
   - No additional CORS configuration needed

## Troubleshooting

### "Instance of '_JsonMap' is not a subtype of type 'List<dynamic>'"
**Cause**: Mismatch between wrapper structure and flat array.
**Solution**: Ensure `getBlogs()` reads wrapper: `data['blogs']` not just `data`.

### "422 Unprocessable Entity"
**Cause**: SHA mismatch (file changed since last fetch).
**Solution**: Fetch latest data before saving, use returned SHA.

### "401 Unauthorized"
**Cause**: Invalid or expired PAT.
**Solution**: Regenerate PAT with `repo` scope, update in Settings.

### "Rate limit exceeded"
**Cause**: Too many API requests.
**Solution**: Wait for rate limit reset, implement caching for reads.

### Changes not appearing on site
**Cause**: GitHub Actions build in progress.
**Solution**: Wait ~2 minutes, check Actions tab for build status.

## Future Enhancements

1. **Optimistic Updates**: Show changes immediately, sync in background
2. **Conflict Resolution**: Handle concurrent edits with merge strategies
3. **Media Management**: Upload images via GitHub API
4. **Draft System**: Save drafts locally before committing
5. **Batch Operations**: Combine multiple changes into single commit
6. **Caching Layer**: Cache reads to reduce API calls
7. **Real-time Preview**: Preview changes before committing

## Conclusion

This GitHub CMS implementation provides a robust, cost-effective solution for managing portfolio content. By leveraging GitHub's infrastructure, we get version control, CI/CD integration, and a developer-friendly workflow without the complexity of traditional CMS platforms.

The architecture is particularly well-suited for:
- Static site generators
- Personal portfolios
- Documentation sites
- Small to medium content volumes
- Teams already using GitHub

For high-traffic sites with frequent updates, consider adding a caching layer or exploring GitHub's GraphQL API for more efficient data fetching.

---

**Project**: Flutter Portfolio with GitHub CMS
**Last Updated**: 2026-06-08
**Framework**: Flutter 3.41.1, Dart 3.11.0
**State Management**: Riverpod 2.5.1
