// ============================================================
// SUPABASE CONFIG — Replace with your project credentials
// ============================================================
const SUPABASE_URL = 'https://tsosrdntzybtcijgjwlk.supabase.co';       // e.g. https://xxxx.supabase.co
const SUPABASE_ANON_KEY = 'sb_publishable_23hymXGOQ4yR02pBk8ndwQ_ux_Dnz8z'; // your anon/public key

// Initialize Supabase client (loaded via CDN in HTML)
let supabase;
function initSupabase() {
  supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  return supabase;
}

// ============================================================
// AUTH HELPERS
// ============================================================
async function signIn(email, password) {
  const { data, error } = await supabase.auth.signInWithPassword({ email, password });
  return { data, error };
}

async function signOut() {
  await supabase.auth.signOut();
  window.location.href = '/admin/login.html';
}

async function getSession() {
  const { data } = await supabase.auth.getSession();
  return data.session;
}

async function requireAuth() {
  const session = await getSession();
  if (!session) {
    window.location.href = '/admin/login.html';
    return null;
  }
  return session;
}

// ============================================================
// PROFILE
// ============================================================
async function getProfile() {
  const { data, error } = await supabase
    .from('profile')
    .select('*')
    .single();
  return { data, error };
}

async function upsertProfile(profile) {
  const { data, error } = await supabase
    .from('profile')
    .upsert(profile, { onConflict: 'id' })
    .select()
    .single();
  return { data, error };
}

// ============================================================
// LECTURES
// ============================================================
async function getLectures(filters = {}) {
  let query = supabase.from('lectures').select('*').order('created_at', { ascending: false });
  if (filters.category) query = query.eq('category', filters.category);
  const { data, error } = await query;
  return { data, error };
}

async function upsertLecture(lecture) {
  const { data, error } = await supabase
    .from('lectures')
    .upsert(lecture)
    .select()
    .single();
  return { data, error };
}

async function deleteLecture(id) {
  const { error } = await supabase.from('lectures').delete().eq('id', id);
  return { error };
}

// ============================================================
// PUBLICATIONS
// ============================================================
async function getPublications() {
  const { data, error } = await supabase
    .from('publications')
    .select('*')
    .order('year', { ascending: false });
  return { data, error };
}

async function upsertPublication(pub) {
  const { data, error } = await supabase
    .from('publications')
    .upsert(pub)
    .select()
    .single();
  return { data, error };
}

async function deletePublication(id) {
  const { error } = await supabase.from('publications').delete().eq('id', id);
  return { error };
}

// ============================================================
// COURSES
// ============================================================
async function getCourses() {
  const { data, error } = await supabase
    .from('courses')
    .select('*')
    .order('created_at', { ascending: false });
  return { data, error };
}

async function upsertCourse(course) {
  const { data, error } = await supabase
    .from('courses')
    .upsert(course)
    .select()
    .single();
  return { data, error };
}

async function deleteCourse(id) {
  const { error } = await supabase.from('courses').delete().eq('id', id);
  return { error };
}

// ============================================================
// BLOG / ARTICLES
// ============================================================
async function getArticles(onlyPublished = false) {
  let query = supabase.from('articles').select('*').order('created_at', { ascending: false });
  if (onlyPublished) query = query.eq('status', 'published');
  const { data, error } = await query;
  return { data, error };
}

async function upsertArticle(article) {
  const { data, error } = await supabase
    .from('articles')
    .upsert(article)
    .select()
    .single();
  return { data, error };
}

async function deleteArticle(id) {
  const { error } = await supabase.from('articles').delete().eq('id', id);
  return { error };
}

// ============================================================
// STORAGE HELPERS (for CV PDF & profile photo)
// ============================================================
async function uploadFile(bucket, path, file) {
  const { data, error } = await supabase.storage
    .from(bucket)
    .upload(path, file, { upsert: true });
  return { data, error };
}

function getPublicUrl(bucket, path) {
  const { data } = supabase.storage.from(bucket).getPublicUrl(path);
  return data.publicUrl;
}

// ============================================================
// YOUTUBE HELPERS
// ============================================================
function extractYouTubeId(url) {
  const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/;
  const match = url.match(regExp);
  return (match && match[2].length === 11) ? match[2] : null;
}

function getYouTubeThumbnail(videoId) {
  return `https://img.youtube.com/vi/${videoId}/mqdefault.jpg`;
}

function getYouTubeEmbedUrl(videoId) {
  return `https://www.youtube.com/embed/${videoId}`;
}
