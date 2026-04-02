import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'SpeakFlow - 온라인 스피치 강의 플랫폼',
  description: '발표 능력 향상을 위한 온라인 스피치 강의 플랫폼',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="ko">
      <body className="bg-gray-50 min-h-screen">
        <header className="bg-white shadow-sm border-b">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-center py-4">
              <h1 className="text-2xl font-bold text-gray-900">SpeakFlow</h1>
              <nav className="space-x-4">
                <a href="/" className="text-gray-600 hover:text-gray-900">홈</a>
                <a href="/categories" className="text-gray-600 hover:text-gray-900">카테고리</a>
                <a href="/courses" className="text-gray-600 hover:text-gray-900">강의</a>
              </nav>
            </div>
          </div>
        </header>
        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {children}
        </main>
      </body>
    </html>
  )
}