import { request, post } from './http.js';

export const fetchCategories = () => request('/api/categories');
export const fetchCategory = id => request(`/api/categories/${id}`);
export const fetchCourses = categoryId => request(categoryId ? `/api/courses?category_id=${categoryId}` : '/api/courses');
export const fetchCourse = id => request(`/api/courses/${id}`);
export const enrollCourse = id => post(`/api/courses/${id}/enroll`, {});
export const fetchCourseLectures = courseId => request(`/api/courses/${courseId}/lectures`);
export const fetchLecture = id => request(`/api/lectures/${id}`);
