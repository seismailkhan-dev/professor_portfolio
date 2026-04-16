// ============================================================
// SUPABASE CONFIG - Replace with your project credentials
// ============================================================
const SUPABASE_URL = 'https://tsosrdntzybtcijgjwlk.supabase.co';       // e.g. https://xxxx.supabase.co
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRzb3NyZG50enlidGNpamdqd2xrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyNTE0ODUsImV4cCI6MjA5MTgyNzQ4NX0.0cbSY60y2tnBegl4iZeDiQJLb3fD1JQpTUJp3wWnqxs'; // your anon/public key

// Global instance
let supabase = null;

/**
 * Initialize Supabase client
 * Explicitly attached to window for scope safety
 */
window.initSupabase = function() {
  console.log('Initializing Supabase...');
  
  if (!SUPABASE_URL || SUPABASE_URL.includes('YOUR_SUPABASE_URL')) {
    console.error('Supabase URL is not configured.');
    return null;
  }
  if (!SUPABASE_ANON_KEY || SUPABASE_ANON_KEY.includes('YOUR_SUPABASE_ANON_KEY')) {
    console.error('Supabase Anon Key is not configured.');
    return null;
  }

  try {
    if (!window.supabase || typeof window.supabase.createClient !== 'function') {
      throw new Error('Supabase SDK (supabase-js) not found. Check CDN script tag.');
    }
    supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    console.log('Supabase client initialized successfully.');
    return supabase;
  } catch (err) {
    console.error('Supabase initialization failed:', err);
    return null;
  }
};

// ============================================================
// AUTH HELPERS - Attached to window
// ============================================================

window.signIn = async function(email, password) {
  if (!supabase) {
    return { error: { message: 'Supabase client not initialized. Check console for setup errors.' } };
  }
  try {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    return { data, error };
  } catch (err) {
    console.error('Auth request exception:', err);
    return { error: { message: err.message || 'Authentication request failed' } };
  }
};

window.signOut = async function() {
  if (supabase) await supabase.auth.signOut();
  window.location.href = '/admin/login.html';
};

window.getSession = async function() {
  if (!supabase) return null;
  const { data } = await supabase.auth.getSession();
  return data.session;
};

window.requireAuth = async function() {
  const session = await window.getSession();
  if (!session) {
    window.location.href = '/admin/login.html';
    return null;
  }
  return session;
};

// ============================================================
// DATA HELPERS - Attached to window
// ============================================================

window.getProfile = async function(id = null) {
  if (id) {
    return await supabase.from('profile').select('*').eq('id', id).maybeSingle();
  }
  return await supabase.from('profile').select('*').single();
};

window.upsertProfile = async function(profile) {
  return await supabase.from('profile').upsert(profile, { onConflict: 'id' }).select().single();
};

window.getLectures = async function(userId = null, filters = {}) {
  let query = supabase.from('lectures').select('*').order('created_at', { ascending: false });
  if (userId) query = query.eq('user_id', userId);
  if (filters.category) query = query.eq('category', filters.category);
  return await query;
};

window.upsertLecture = async function(lecture) {
  return await supabase.from('lectures').upsert(lecture).select().single();
};

window.deleteLecture = async function(id) {
  return await supabase.from('lectures').delete().eq('id', id);
};

window.getPublications = async function(userId = null) {
  let query = supabase.from('publications').select('*').order('year', { ascending: false });
  if (userId) query = query.eq('user_id', userId);
  return await query;
};

window.upsertPublication = async function(pub) {
  return await supabase.from('publications').upsert(pub).select().single();
};

window.deletePublication = async function(id) {
  return await supabase.from('publications').delete().eq('id', id);
};

window.getCourses = async function(userId = null) {
  let query = supabase.from('courses').select('*').order('created_at', { ascending: false });
  if (userId) query = query.eq('user_id', userId);
  return await query;
};

window.upsertCourse = async function(course) {
  return await supabase.from('courses').upsert(course).select().single();
};

window.deleteCourse = async function(id) {
  return await supabase.from('courses').delete().eq('id', id);
};

window.getArticles = async function(onlyPublished = false, userId = null) {
  let query = supabase.from('articles').select('*').order('created_at', { ascending: false });
  if (onlyPublished) query = query.eq('status', 'published');
  if (userId) query = query.eq('user_id', userId);
  return await query;
};

window.upsertArticle = async function(article) {
  return await supabase.from('articles').upsert(article).select().single();
};

window.deleteArticle = async function(id) {
  return await supabase.from('articles').delete().eq('id', id);
};

window.uploadFile = async function(bucket, path, file) {
  return await supabase.storage.from(bucket).upload(path, file, { upsert: true });
};

window.getPublicUrl = function(bucket, path) {
  const { data } = supabase.storage.from(bucket).getPublicUrl(path);
  return data.publicUrl;
};

// ============================================================
// UTILITIES - Attached to window
// ============================================================

window.extractYouTubeId = function(url) {
  const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/;
  const match = url.match(regExp);
  return (match && match[2].length === 11) ? match[2] : null;
};

window.getYouTubeThumbnail = function(videoId) {
  return `https://img.youtube.com/vi/${videoId}/mqdefault.jpg`;
};

window.getYouTubeEmbedUrl = function(videoId) {
  return `https://www.youtube.com/embed/${videoId}`;
};

console.log('supabase.js helper library loaded and attached to window.');
