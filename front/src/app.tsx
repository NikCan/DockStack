import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { BrowserRouter, Route, Routes } from 'react-router-dom';
import { Toaster } from '@/components/ui/sonner';
import { TodosListPage } from '@/pages/todos-list';
import { TodoDetailPage } from '@/pages/todo-detail';
import { NotFoundPage } from '@/pages/not-found';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 30_000,
      refetchOnWindowFocus: false,
      retry: 1,
    },
  },
});

export function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <div className="min-h-screen bg-background text-foreground">
          <header className="border-b">
            <div className="container py-4">
              <h1 className="text-xl font-semibold">Todos - week4</h1>
            </div>
          </header>
          <main className="container py-6">
            <Routes>
              <Route path="/" element={<TodosListPage />} />
              <Route path="/todos/:id" element={<TodoDetailPage />} />
              <Route path="*" element={<NotFoundPage />} />
            </Routes>
          </main>
        </div>
      </BrowserRouter>
      <Toaster richColors closeButton />
    </QueryClientProvider>
  );
}
