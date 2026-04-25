"use client";

import React, { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Plus, Play, CheckCircle, Clock, XCircle, ChevronRight, LayoutDashboard, FileUp, Settings, LogOut } from 'lucide-react';
import api from '@/lib/api';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

interface Job {
  id: number;
  title: str;
  status: 'pending' | 'running' | 'completed' | 'failed';
  created_at: string;
}

export default function Dashboard() {
  const [jobs, setJobs] = useState<Job[]>([]);
  const [loading, setLoading] = useState(true);
  const router = useRouter();

  useEffect(() => {
    const fetchJobs = async () => {
      try {
        const response = await api.get('/jobs/');
        setJobs(response.data);
      } catch (err) {
        // If unauthorized, redirect to login
        router.push('/login');
      } finally {
        setLoading(false);
      }
    };

    fetchJobs();
  }, [router]);

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'completed': return <CheckCircle className="w-5 h-5 text-emerald-500" />;
      case 'running': return <Clock className="w-5 h-5 text-blue-500 animate-pulse" />;
      case 'pending': return <Clock className="w-5 h-5 text-slate-500" />;
      case 'failed': return <XCircle className="w-5 h-5 text-red-500" />;
      default: return null;
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    router.push('/login');
  };

  return (
    <div className="flex min-h-screen bg-slate-950 text-white">
      {/* Sidebar */}
      <aside className="w-64 border-r border-slate-800 bg-slate-900/50 p-6 flex flex-col gap-8">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center font-bold">M</div>
          <span className="font-bold text-xl">MitoGEx</span>
        </div>

        <nav className="flex-1 space-y-2">
          <a href="/dashboard" className="flex items-center gap-3 px-4 py-3 bg-blue-600/10 text-blue-400 rounded-lg border border-blue-600/20 font-medium transition-all">
            <LayoutDashboard className="w-5 h-5" />
            Dashboard
          </a>
          <a href="/upload" className="flex items-center gap-3 px-4 py-3 text-slate-400 hover:text-white hover:bg-slate-800 rounded-lg transition-all">
            <FileUp className="w-5 h-5" />
            Upload Data
          </a>
          <a href="/settings" className="flex items-center gap-3 px-4 py-3 text-slate-400 hover:text-white hover:bg-slate-800 rounded-lg transition-all">
            <Settings className="w-5 h-5" />
            Settings
          </a>
        </nav>

        <button 
          onClick={handleLogout}
          className="flex items-center gap-3 px-4 py-3 text-slate-400 hover:text-red-400 hover:bg-red-400/10 rounded-lg transition-all mt-auto"
        >
          <LogOut className="w-5 h-5" />
          Logout
        </button>
      </aside>

      {/* Main Content */}
      <main className="flex-1 p-10 overflow-y-auto">
        <header className="flex justify-between items-center mb-10">
          <div>
            <h1 className="text-3xl font-bold">My Projects</h1>
            <p className="text-slate-400 mt-1">Manage and track your mitochondrial analysis jobs.</p>
          </div>
          <button 
            onClick={() => router.push('/new-run')}
            className="flex items-center gap-2 bg-blue-600 hover:bg-blue-500 px-6 py-3 rounded-lg font-semibold transition-all shadow-lg shadow-blue-900/20"
          >
            <Plus className="w-5 h-5" />
            New Analysis Run
          </button>
        </header>

        {loading ? (
          <div className="flex items-center justify-center h-64">
            <div className="w-8 h-8 border-4 border-blue-600 border-t-transparent rounded-full animate-spin"></div>
          </div>
        ) : jobs.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-96 border-2 border-dashed border-slate-800 rounded-2xl bg-slate-900/30">
            <div className="w-16 h-16 bg-slate-800 rounded-full flex items-center justify-center mb-4 text-slate-600">
              <Plus className="w-8 h-8" />
            </div>
            <h3 className="text-xl font-semibold mb-2">No projects found</h3>
            <p className="text-slate-400 mb-6 text-center max-w-sm">You haven't started any analysis runs yet. Upload some data and start your first project.</p>
            <button 
              onClick={() => router.push('/new-run')}
              className="text-blue-400 font-medium hover:text-blue-300 transition-colors"
            >
              Start your first run →
            </button>
          </div>
        ) : (
          <div className="space-y-4">
            {jobs.map((job) => (
              <div 
                key={job.id}
                className="group flex items-center justify-between p-6 bg-slate-900 border border-slate-800 rounded-xl hover:border-slate-700 transition-all cursor-pointer"
                onClick={() => router.push(`/jobs/${job.id}`)}
              >
                <div className="flex items-center gap-6">
                  <div className="p-3 bg-slate-800 rounded-lg">
                    {getStatusIcon(job.status)}
                  </div>
                  <div>
                    <h3 className="text-lg font-bold group-hover:text-blue-400 transition-colors">{job.title}</h3>
                    <p className="text-sm text-slate-400">ID: #{job.id} • Created on {new Date(job.created_at).toLocaleDateString()}</p>
                  </div>
                </div>
                
                <div className="flex items-center gap-8">
                  <div className="text-right">
                    <span className={cn(
                      "px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider",
                      job.status === 'completed' && "bg-emerald-900/30 text-emerald-400 border border-emerald-800/50",
                      job.status === 'running' && "bg-blue-900/30 text-blue-400 border border-blue-800/50",
                      job.status === 'pending' && "bg-slate-800 text-slate-400 border border-slate-700",
                      job.status === 'failed' && "bg-red-900/30 text-red-400 border border-red-800/50",
                    )}>
                      {job.status}
                    </span>
                  </div>
                  <ChevronRight className="w-5 h-5 text-slate-600 group-hover:text-white transition-colors" />
                </div>
              </div>
            ))}
          </div>
        )}
      </main>
    </div>
  );
}
