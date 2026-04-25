import React from 'react';

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24 bg-slate-900 text-white">
      <div className="z-10 max-w-5xl w-full items-center justify-center font-mono text-sm flex flex-col gap-8">
        <h1 className="text-6xl font-bold text-blue-400">MitoGEx Web</h1>
        <p className="text-xl text-slate-300">
          Integrated Platform for Streamlined Human Mitochondrial Genome Analysis
        </p>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 w-full mt-12">
          <div className="p-6 bg-slate-800 rounded-lg border border-slate-700">
            <h2 className="text-xl font-semibold mb-2">High Throughput</h2>
            <p className="text-slate-400">Process massive FASTQ and BAM files in the background.</p>
          </div>
          <div className="p-6 bg-slate-800 rounded-lg border border-slate-700">
            <h2 className="text-xl font-semibold mb-2">SeaweedFS</h2>
            <p className="text-slate-400">Scalable, self-hosted S3-compatible object storage.</p>
          </div>
          <div className="p-6 bg-slate-800 rounded-lg border border-slate-700">
            <h2 className="text-xl font-semibold mb-2">Self-Hosted</h2>
            <p className="text-slate-400">Deploy on your own server with total data control.</p>
          </div>
        </div>
      </div>
    </main>
  );
}
