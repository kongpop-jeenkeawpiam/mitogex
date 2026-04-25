"use client";

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { ArrowLeft, Upload, Play, Check, AlertCircle } from 'lucide-react';
import api from '@/lib/api';
import axios from 'axios';

export default function NewRun() {
  const [title, setTitle] = useState('');
  const [file, setFile] = useState<File | null>(null);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [status, setStatus] = useState<'idle' | 'uploading' | 'creating' | 'success' | 'error'>('idle');
  const [errorMessage, setErrorMessage] = useState('');
  const router = useRouter();

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setFile(e.target.files[0]);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!file || !title) return;

    try {
      setStatus('uploading');
      // 1. Get presigned URL
      const { data: uploadData } = await api.post('/jobs/upload-url', {
        filename: file.name
      });

      // 2. Upload directly to SeaweedFS
      await axios.put(uploadData.url, file, {
        headers: { 'Content-Type': file.type },
        onUploadProgress: (progressEvent) => {
          const percentCompleted = Math.round((progressEvent.loaded * 100) / (progressEvent.total || 1));
          setUploadProgress(percentCompleted);
        }
      });

      setStatus('creating');
      // 3. Create the job in the backend
      await api.post('/jobs/', {
        title: title,
        parameters: {
          input_keys: [uploadData.key],
          threads: 4
        }
      });

      setStatus('success');
      setTimeout(() => router.push('/dashboard'), 2000);
    } catch (err: any) {
      console.error(err);
      setStatus('error');
      setErrorMessage(err.response?.data?.detail || 'An unexpected error occurred during upload.');
    }
  };

  return (
    <div className="min-h-screen bg-slate-950 text-white p-10">
      <div className="max-w-2xl mx-auto">
        <button 
          onClick={() => router.back()}
          className="flex items-center gap-2 text-slate-400 hover:text-white mb-8 transition-colors"
        >
          <ArrowLeft className="w-4 h-4" />
          Back to Dashboard
        </button>

        <header className="mb-10">
          <h1 className="text-3xl font-bold">New Analysis Run</h1>
          <p className="text-slate-400 mt-2">Configure your project and upload your sequencing data.</p>
        </header>

        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-8 shadow-xl">
          <form onSubmit={handleSubmit} className="space-y-8">
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-slate-300 mb-2">Project Title</label>
                <input
                  type="text"
                  required
                  placeholder="e.g., Patient_001_Mitochondria"
                  className="w-full rounded-lg bg-slate-800 border border-slate-700 px-4 py-3 text-white focus:border-blue-500 outline-none transition-all"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  disabled={status !== 'idle' && status !== 'error'}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-slate-300 mb-2">Sequencing Data (FASTQ/BAM)</label>
                <div className="relative group">
                  <input
                    type="file"
                    required
                    className="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-10"
                    onChange={handleFileChange}
                    disabled={status !== 'idle' && status !== 'error'}
                  />
                  <div className="border-2 border-dashed border-slate-700 group-hover:border-blue-500 rounded-xl p-10 text-center transition-all bg-slate-800/50">
                    <Upload className="w-10 h-10 text-slate-500 group-hover:text-blue-400 mx-auto mb-4 transition-colors" />
                    {file ? (
                      <div>
                        <p className="text-blue-400 font-semibold">{file.name}</p>
                        <p className="text-slate-500 text-sm mt-1">{(file.size / (1024 * 1024)).toFixed(2)} MB</p>
                      </div>
                    ) : (
                      <div>
                        <p className="text-slate-300 font-medium">Click or drag and drop to upload</p>
                        <p className="text-slate-500 text-sm mt-1">Supports .fastq, .fastq.gz, .bam</p>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            </div>

            {status === 'uploading' && (
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span className="text-blue-400 font-medium">Uploading to SeaweedFS...</span>
                  <span className="text-slate-400">{uploadProgress}%</span>
                </div>
                <div className="w-full bg-slate-800 rounded-full h-2">
                  <div 
                    className="bg-blue-600 h-2 rounded-full transition-all duration-300" 
                    style={{ width: `${uploadProgress}%` }}
                  ></div>
                </div>
              </div>
            )}

            {status === 'creating' && (
              <div className="flex items-center gap-3 text-emerald-400 bg-emerald-400/10 p-4 rounded-lg border border-emerald-400/20">
                <div className="w-4 h-4 border-2 border-emerald-400 border-t-transparent rounded-full animate-spin"></div>
                <span className="font-medium">Initializing analysis pipeline...</span>
              </div>
            )}

            {status === 'success' && (
              <div className="flex items-center gap-3 text-emerald-400 bg-emerald-400/10 p-4 rounded-lg border border-emerald-400/20">
                <Check className="w-5 h-5" />
                <span className="font-medium">Job created successfully! Redirecting...</span>
              </div>
            )}

            {status === 'error' && (
              <div className="flex items-center gap-3 text-red-400 bg-red-400/10 p-4 rounded-lg border border-red-400/20">
                <AlertCircle className="w-5 h-5" />
                <span className="font-medium">{errorMessage}</span>
              </div>
            )}

            <button
              type="submit"
              disabled={status !== 'idle' && status !== 'error'}
              className="w-full flex items-center justify-center gap-2 rounded-lg bg-blue-600 px-4 py-4 font-bold text-white hover:bg-blue-500 disabled:opacity-50 transition-all shadow-lg shadow-blue-900/20"
            >
              <Play className="w-5 h-5" />
              Start Analysis
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
