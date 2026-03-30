import { request, post } from './http.js';

export const updateLectureProgress = (lectureId, watched) =>
  post(`/api/lectures/${lectureId}/progress`, { watched });

export const fetchMyCourses = () => request('/api/users/me/courses');
export const fetchMyProgress = () => request('/api/users/me/progress');
