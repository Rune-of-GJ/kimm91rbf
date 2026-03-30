import { post } from './http.js';

export const signup = payload => post('/api/auth/signup', payload);
export const login = payload => post('/api/auth/login', payload);
export const refreshSession = () => post('/api/auth/refresh', {});
export const logout = () => post('/api/auth/logout', {});
