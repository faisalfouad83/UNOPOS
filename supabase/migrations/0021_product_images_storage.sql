-- Product photos live in a private Storage bucket, one folder per store
-- (<store_id>/<file>). Only the signed-in store can read or change its own
-- folder; nothing is public. Plus an index for the paged invoice list.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('product-images', 'product-images', false, 1048576, array['image/png', 'image/jpeg', 'image/webp'])
on conflict (id) do nothing;

create policy "product images: read own store"
  on storage.objects for select to authenticated
  using (bucket_id = 'product-images' and (storage.foldername(name))[1] = public.current_store_id());

create policy "product images: add to own store"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'product-images' and (storage.foldername(name))[1] = public.current_store_id());

create policy "product images: replace in own store"
  on storage.objects for update to authenticated
  using (bucket_id = 'product-images' and (storage.foldername(name))[1] = public.current_store_id())
  with check (bucket_id = 'product-images' and (storage.foldername(name))[1] = public.current_store_id());

create policy "product images: remove from own store"
  on storage.objects for delete to authenticated
  using (bucket_id = 'product-images' and (storage.foldername(name))[1] = public.current_store_id());

create index if not exists idx_sales_store_completed on public.sales (store_id, completed_at desc);
