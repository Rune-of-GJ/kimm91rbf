'use client'

import { useEffect, useState } from 'react'
import axios from 'axios'

type User = { id: number; email: string; name: string }
type Category = { id: number; name: string; description?: string }
type Course = {
  id: number
  title: string
  description: string
  category_id: number
  instructor_name: string
  thumbnail_url?: string
}

type ProgressItem = {
  course_id: number
  course_title: string
  total_lectures: number
  watched_lectures: number
  progress_rate: number
  lectures: { lecture_id: number; lecture_title: string; order_no: number; watched: boolean; watched_at: string | null }[]
}

export default function Home() {
  const [user, setUser] = useState<User | null>(null)
  const [categories, setCategories] = useState<Category[]>([])
  const [courses, setCourses] = useState<Course[]>([])
  const [selectedCategoryId, setSelectedCategoryId] = useState<number | null>(null)
  const [myCourses, setMyCourses] = useState<Course[]>([])
  const [progress, setProgress] = useState<ProgressItem[]>([])
  const [loading, setLoading] = useState(false)
  const [showAuthModal, setShowAuthModal] = useState(false)
  const [authMode, setAuthMode] = useState<'login' | 'signup'>('login')
  const [message, setMessage] = useState<string>('')
  const [currentTab, setCurrentTab] = useState<'browse' | 'my-courses' | 'progress'>('browse')

  const apiClient = axios.create({
    baseURL: '/api',
    withCredentials: true,
    headers: { 'Content-Type': 'application/json' },
  })

  const loadCategories = async () => {
    try {
      const response = await apiClient.get<Category[]>('/categories')
      setCategories(response.data)
    } catch (err) {
      console.error('카테고리 로딩 실패', err)
    }
  }

  const loadCourses = async () => {
    try {
      const response = await apiClient.get<Course[]>('/courses')
      setCourses(response.data)
    } catch (err) {
      console.error('강의 로딩 실패', err)
    }
  }

  const loadMyCourses = async () => {
    if (!user) return
    try {
      const response = await apiClient.get<Course[]>('/users/me/courses')
      setMyCourses(response.data)
    } catch (err) {
      console.error('내 강의 로딩 실패', err)
    }
  }

  const loadProgress = async () => {
    if (!user) return
    try {
      const response = await apiClient.get<ProgressItem[]>('/users/me/progress')
      setProgress(response.data)
    } catch (err) {
      console.error('진도 로딩 실패', err)
    }
  }

  const signup = async (email: string, name: string, password: string) => {
    setLoading(true)
    try {
      const response = await apiClient.post<{ user: User }>('/auth/signup', { email, name, password })
      setUser(response.data.user)
      setMessage('회원가입 완료! 환영합니다.')
      setShowAuthModal(false)
      await loadMyCourses()
    } catch (err: any) {
      setMessage(`회원가입 실패: ${err.response?.data?.errors?.join(', ') || err.message}`)
    } finally {
      setLoading(false)
    }
  }

  const login = async (email: string, password: string) => {
    setLoading(true)
    try {
      const response = await apiClient.post<{ user: User }>('/auth/login', { email, password })
      setUser(response.data.user)
      setMessage('로그인 성공!')
      setShowAuthModal(false)
      await loadMyCourses()
    } catch (err: any) {
      setMessage(`로그인 실패: ${err.response?.data?.error || err.message}`)
    } finally {
      setLoading(false)
    }
  }

  const logout = async () => {
    setLoading(true)
    try {
      await apiClient.post('/auth/logout')
      setUser(null)
      setMyCourses([])
      setProgress([])
      setCurrentTab('browse')
      setMessage('로그아웃 완료')
    } catch (err) {
      console.error('로그아웃 실패', err)
    } finally {
      setLoading(false)
    }
  }

  const enrollCourse = async (courseId: number) => {
    if (!user) {
      setShowAuthModal(true)
      return
    }
    setLoading(true)
    try {
      await apiClient.post(`/courses/${courseId}/enroll`)
      setMessage('수강신청 완료!')
      await loadMyCourses()
    } catch (err: any) {
      setMessage(`수강신청 실패: ${err.response?.data?.error || err.message}`)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadCategories()
    loadCourses()
  }, [])

  const filteredCourses = selectedCategoryId
    ? courses.filter((course) => course.category_id === selectedCategoryId)
    : courses

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-slate-900">
      {/* 헤더 */}
      <header className="sticky top-0 z-50 border-b border-blue-500/20 bg-slate-900/95 backdrop-blur">
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="text-2xl font-black text-blue-400">🎤 SpeakFlow</div>
            <span className="text-slate-400 text-sm">발표 능력 향상 플랫폼</span>
          </div>
          <div className="flex items-center gap-4">
            {user ? (
              <>
                <div className="text-right text-sm hidden sm:block">
                  <p className="text-blue-300 font-semibold">{user.name}</p>
                  <p className="text-slate-400 text-xs">{user.email}</p>
                </div>
                <button onClick={logout} className="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded font-medium transition">
                  로그아웃
                </button>
              </>
            ) : (
              <button onClick={() => { setShowAuthModal(true); setAuthMode('login') }} className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded font-medium transition">
                로그인
              </button>
            )}
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-6 py-12">
        {/* 히어로 */}
        {!user && (
          <section className="mb-12 text-center py-12">
            <h1 className="text-5xl font-black text-white mb-4">뛰어난 발표자로 거듭나세요</h1>
            <p className="text-xl text-slate-300 mb-6">전문 강사와 함께하는 스피치, 발표, 소통 능력 향상</p>
            <button
              onClick={() => { setShowAuthModal(true); setAuthMode('signup') }}
              className="px-8 py-3 bg-gradient-to-r from-blue-500 to-cyan-500 hover:from-blue-600 hover:to-cyan-600 text-white rounded-lg font-bold text-lg transition shadow-lg"
            >
              무료로 시작하기
            </button>
          </section>
        )}

        {/* 메시지 표시 */}
        {message && (
          <div className="mb-4 p-4 bg-blue-500/20 border border-blue-500 rounded text-blue-200 text-center">
            {message}
          </div>
        )}

        {/* 탭 네비게이션 */}
        {user && (
          <div className="flex gap-4 mb-8 border-b border-slate-700">
            <button
              onClick={() => setCurrentTab('browse')}
              className={`px-4 py-3 font-semibold border-b-2 transition ${currentTab === 'browse' ? 'text-blue-400 border-blue-400' : 'text-slate-400 border-transparent hover:text-slate-300'}`}
            >
              강의 탐색
            </button>
            <button
              onClick={() => { setCurrentTab('my-courses'); loadMyCourses() }}
              className={`px-4 py-3 font-semibold border-b-2 transition ${currentTab === 'my-courses' ? 'text-blue-400 border-blue-400' : 'text-slate-400 border-transparent hover:text-slate-300'}`}
            >
              내 강의
            </button>
            <button
              onClick={() => { setCurrentTab('progress'); loadProgress() }}
              className={`px-4 py-3 font-semibold border-b-2 transition ${currentTab === 'progress' ? 'text-blue-400 border-blue-400' : 'text-slate-400 border-transparent hover:text-slate-300'}`}
            >
              학습 진도
            </button>
          </div>
        )}

        {/* 강의 탐색 탭 */}
        {currentTab === 'browse' && (
          <section>
            <div className="flex gap-4 mb-6 overflow-x-auto pb-2">
              <button
                onClick={() => setSelectedCategoryId(null)}
                className={`px-4 py-2 rounded-full font-semibold whitespace-nowrap transition ${selectedCategoryId === null ? 'bg-blue-600 text-white' : 'bg-slate-700 text-slate-300 hover:bg-slate-600'}`}
              >
                전체
              </button>
              {categories.map((cat) => (
                <button
                  key={cat.id}
                  onClick={() => setSelectedCategoryId(cat.id)}
                  className={`px-4 py-2 rounded-full font-semibold whitespace-nowrap transition ${selectedCategoryId === cat.id ? 'bg-blue-600 text-white' : 'bg-slate-700 text-slate-300 hover:bg-slate-600'}`}
                >
                  {cat.name}
                </button>
              ))}
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {filteredCourses.map((course) => (
                <div key={course.id} className="bg-slate-800 border border-slate-700 hover:border-blue-500 rounded-lg overflow-hidden transition group">
                  <div className="h-40 bg-gradient-to-br from-blue-500 to-cyan-600 flex items-center justify-center text-6xl">
                    🎯
                  </div>
                  <div className="p-6">
                    <h3 className="font-bold text-lg text-white mb-1 group-hover:text-blue-300 transition line-clamp-2">{course.title}</h3>
                    <p className="text-sm text-slate-400 mb-2">👨‍🏫 {course.instructor_name}</p>
                    <p className="text-slate-300 text-sm mb-4 line-clamp-2">{course.description}</p>
                    <button
                      onClick={() => enrollCourse(course.id)}
                      disabled={loading}
                      className="w-full px-4 py-2 bg-blue-600 hover:bg-blue-700 disabled:bg-slate-600 text-white rounded font-semibold transition"
                    >
                      수강신청
                    </button>
                  </div>
                </div>
              ))}
            </div>
            {filteredCourses.length === 0 && (
              <div className="text-center py-12">
                <p className="text-slate-400">등록된 강의가 없습니다.</p>
              </div>
            )}
          </section>
        )}

        {/* 내 강의 탭 */}
        {currentTab === 'my-courses' && (
          <section>
            {!user ? (
              <div className="text-center py-12">
                <p className="text-slate-400 mb-4">로그인 후 내 강의를 확인할 수 있습니다.</p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {myCourses.map((course) => (
                  <div key={course.id} className="bg-slate-800 border border-green-500/30 rounded-lg p-6">
                    <h3 className="font-bold text-lg text-white mb-2">{course.title}</h3>
                    <p className="text-sm text-slate-400 mb-2">👨‍🏫 {course.instructor_name}</p>
                    <p className="text-slate-300 text-sm">{course.description}</p>
                  </div>
                ))}
              </div>
            )}
            {user && myCourses.length === 0 && (
              <div className="text-center py-12">
                <p className="text-slate-400 mb-4">아직 수강하는 강의가 없습니다.</p>
                <button onClick={() => setCurrentTab('browse')} className="text-blue-400 hover:text-blue-300">강의 탐색하기</button>
              </div>
            )}
          </section>
        )}

        {/* 학습 진도 탭 */}
        {currentTab === 'progress' && (
          <section>
            {!user ? (
              <div className="text-center py-12">
                <p className="text-slate-400">로그인 후 학습 진도를 확인할 수 있습니다.</p>
              </div>
            ) : (
              <div className="space-y-6">
                {progress.map((item) => (
                  <div key={item.course_id} className="bg-slate-800 border border-slate-700 rounded-lg p-6">
                    <div className="mb-4">
                      <h3 className="font-bold text-lg text-white mb-2">{item.course_title}</h3>
                      <div className="flex items-center gap-3">
                        <div className="flex-1 bg-slate-700 rounded-full h-3 overflow-hidden">
                          <div className="bg-gradient-to-r from-blue-500 to-cyan-500 h-full" style={{ width: `${item.progress_rate}%` }} />
                        </div>
                        <span className="text-sm font-semibold text-blue-400">{item.progress_rate}%</span>
                      </div>
                      <p className="text-xs text-slate-400 mt-1">{item.watched_lectures} / {item.total_lectures} 강의 수강</p>
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
                      {item.lectures.map((lecture) => (
                        <div key={lecture.lecture_id} className={`px-3 py-2 rounded text-sm ${lecture.watched ? 'bg-green-500/20 text-green-300' : 'bg-slate-700 text-slate-300'}`}>
                          <span className="font-semibold">{lecture.order_no}.</span> {lecture.lecture_title} {lecture.watched && '✓'}
                        </div>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            )}
            {user && progress.length === 0 && (
              <div className="text-center py-12">
                <p className="text-slate-400">수강한 강의가 없어 진도 정보가 없습니다.</p>
              </div>
            )}
          </section>
        )}
      </main>

      {/* 인증 모달 */}
      {showAuthModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="bg-slate-800 rounded-lg p-8 max-w-md w-full mx-4 border border-slate-700">
            <h2 className="text-2xl font-bold text-white mb-6 flex gap-2">
              <button onClick={() => setAuthMode('login')} className={`flex-1 pb-2 transition border-b-2 ${authMode === 'login' ? 'text-blue-400 border-blue-400' : 'text-slate-400 border-transparent'}`}>
                로그인
              </button>
              <button onClick={() => setAuthMode('signup')} className={`flex-1 pb-2 transition border-b-2 ${authMode === 'signup' ? 'text-blue-400 border-blue-400' : 'text-slate-400 border-transparent'}`}>
                회원가입
              </button>
            </h2>
            {authMode === 'login' ? <LoginForm onSubmit={login} loading={loading} /> : <SignupForm onSubmit={signup} loading={loading} />}
            <button onClick={() => setShowAuthModal(false)} className="mt-4 text-slate-400 hover:text-slate-300 text-sm">
              닫기
            </button>
          </div>
        </div>
      )}
    </div>
  )
}

function LoginForm({ onSubmit, loading }: { onSubmit: (email: string, password: string) => void; loading: boolean }) {
  const [email, setEmail] = useState('instructor@speakflow.kr')
  const [password, setPassword] = useState('password123')

  return (
    <div className="space-y-4">
      <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} className="w-full px-4 py-2 bg-slate-700 border border-slate-600 rounded text-white placeholder-slate-400" placeholder="이메일" />
      <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} className="w-full px-4 py-2 bg-slate-700 border border-slate-600 rounded text-white placeholder-slate-400" placeholder="비밀번호" />
      <button onClick={() => onSubmit(email, password)} disabled={loading} className="w-full px-4 py-2 bg-blue-600 hover:bg-blue-700 disabled:bg-slate-600 text-white rounded font-semibold transition">
        {loading ? '로그인 중...' : '로그인'}
      </button>
    </div>
  )
}

function SignupForm({ onSubmit, loading }: { onSubmit: (email: string, name: string, password: string) => void; loading: boolean }) {
  const [email, setEmail] = useState('newuser@example.com')
  const [name, setName] = useState('새 사용자')
  const [password, setPassword] = useState('password123')

  return (
    <div className="space-y-4">
      <input type="text" value={name} onChange={(e) => setName(e.target.value)} className="w-full px-4 py-2 bg-slate-700 border border-slate-600 rounded text-white placeholder-slate-400" placeholder="이름" />
      <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} className="w-full px-4 py-2 bg-slate-700 border border-slate-600 rounded text-white placeholder-slate-400" placeholder="이메일" />
      <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} className="w-full px-4 py-2 bg-slate-700 border border-slate-600 rounded text-white placeholder-slate-400" placeholder="비밀번호" />
      <button onClick={() => onSubmit(email, name, password)} disabled={loading} className="w-full px-4 py-2 bg-green-600 hover:bg-green-700 disabled:bg-slate-600 text-white rounded font-semibold transition">
        {loading ? '회원가입 중...' : '회원가입'}
      </button>
    </div>
  )
}
